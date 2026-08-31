import QtQuick
import qs.modules.common

ApiStrategy {
    property bool isReasoning: false
    property string toolCallId: ""
    property string toolCallName: ""
    property string toolCallArgs: ""
    
    function buildEndpoint(model: AiModel): string {
        // console.log("[AI] Endpoint: " + model.endpoint);
        return model.endpoint;
    }

    function buildRequestData(model: AiModel, messages, systemPrompt: string, temperature: real, tools: list<var>, filePath: string) {
        let baseData = {
            "model": model.model,
            "messages": [
                {role: "system", content: systemPrompt},
                ...messages.map(message => {
                    const hasFunctionCall = message.functionCall != undefined && message.functionName.length > 0;
                    let messageData = {
                        "role": message.role,
                        "content": message.rawContent,
                    };
                    if (hasFunctionCall) {
                        if (message.functionResponse?.length > 0) {
                            messageData.name = message.functionName;
                            messageData.role = "tool";
                            messageData.content = message.functionResponse;
                            messageData.tool_call_id = message.functionCall.id || "call_unknown";
                        }
                    }
                    return messageData;
                }),
            ],
            "stream": true,
            "tools": tools,
            "temperature": temperature,
        };
        if (Config.options.ai.thinkingMode && (model.model.includes("o1") || model.model.includes("o3") || model.model.includes("reasoning"))) {
            baseData["reasoning_effort"] = "medium";
        }
        return model.extraParams ? Object.assign({}, baseData, model.extraParams) : baseData;
    }

    function buildAuthorizationHeader(apiKeyEnvVarName: string): string {
        return `-H "Authorization: Bearer \$\{${apiKeyEnvVarName}\}"`;
    }

    function parseResponseLine(line, message) {
        // Remove 'data: ' prefix if present and trim whitespace
        let cleanData = line.trim();
        if (cleanData.startsWith("data:")) {
            cleanData = cleanData.slice(5).trim();
        }

        // console.log("[AI] OpenAI: Data:", cleanData);
        
        // Handle special cases
        if (!cleanData || cleanData.startsWith(":")) return {};
        if (cleanData === "[DONE]") {
            return { finished: true };
        }
        
        // Real stuff
        try {
            const dataJson = JSON.parse(cleanData);

            // Error response handling
            if (dataJson.error) {
                const errorMsg = `**Error**: ${dataJson.error.message || JSON.stringify(dataJson.error)}`;
                message.rawContent += errorMsg;
                message.content += errorMsg;
                return { finished: true };
            }

            let newContent = "";

            const responseContent = dataJson.choices[0]?.delta?.content || dataJson.message?.content;
            const responseReasoning = dataJson.choices[0]?.delta?.reasoning || dataJson.choices[0]?.delta?.reasoning_content;

            // Function call handling
            if (dataJson.choices && dataJson.choices[0]?.delta?.tool_calls) {
                const functionCall = dataJson.choices[0].delta.tool_calls[0];
                if (functionCall.id) {
                    toolCallId = functionCall.id;
                }
                if (functionCall.function?.name) {
                    toolCallName = functionCall.function.name;
                }
                if (functionCall.function?.arguments) {
                    toolCallArgs += functionCall.function.arguments;
                }
                return {};
            }

            if (dataJson.choices && (dataJson.choices[0]?.finish_reason === "tool_calls" || dataJson.choices[0]?.finish_reason === "stop")) {
                if (toolCallName.length > 0) {
                    let functionArgs = {};
                    if (toolCallArgs.length > 0) {
                        try {
                            functionArgs = JSON.parse(toolCallArgs);
                        } catch (e) {
                            console.log("[AI] OpenAI: Could not parse tool arguments:", e);
                        }
                    }
                    const newContent = `\n\n[[ Function: ${toolCallName}(${JSON.stringify(functionArgs, null, 2)}) ]]\n`;
                    message.rawContent += newContent;
                    message.content += newContent;
                    message.functionName = toolCallName;
                    const returnData = { functionCall: { name: toolCallName, args: functionArgs, id: toolCallId } };
                    toolCallId = "";
                    toolCallName = "";
                    toolCallArgs = "";
                    return returnData;
                }
            }

            if (dataJson.done && toolCallName.length > 0) {
                let functionArgs = {};
                if (toolCallArgs.length > 0) {
                    try {
                        functionArgs = JSON.parse(toolCallArgs);
                    } catch (e) {
                        console.log("[AI] OpenAI: Could not parse tool arguments:", e);
                    }
                }
                const newContent = `\n\n[[ Function: ${toolCallName}(${JSON.stringify(functionArgs, null, 2)}) ]]\n`;
                message.rawContent += newContent;
                message.content += newContent;
                message.functionName = toolCallName;
                const returnData = { functionCall: { name: toolCallName, args: functionArgs, id: toolCallId }, finished: true };
                toolCallId = "";
                toolCallName = "";
                toolCallArgs = "";
                return returnData;
            }

            if (responseContent && responseContent.length > 0) {
                if (isReasoning) {
                    isReasoning = false;
                    const endBlock = "\n\n</think>\n\n";
                    message.content += endBlock;
                    message.rawContent += endBlock;
                }
                newContent = responseContent;
            } else if (responseReasoning && responseReasoning.length > 0) {
                if (!isReasoning) {
                    isReasoning = true;
                    const startBlock = "\n\n<think>\n\n";
                    message.rawContent += startBlock;
                    message.content += startBlock;
                }
                newContent = responseReasoning;
            }

            message.content += newContent;
            message.rawContent += newContent;

            // Usage metadata
            if (dataJson.usage) {
                return {
                    tokenUsage: {
                        input: dataJson.usage.prompt_tokens ?? -1,
                        output: dataJson.usage.completion_tokens ?? -1,
                        total: dataJson.usage.total_tokens ?? -1
                    }
                };
            }

            if (dataJson.done) {
                return { finished: true };
            }
            
        } catch (e) {
            console.log("[AI] OpenAI: Could not parse line: ", e);
            message.rawContent += line;
            message.content += line;
        }
        
        return {};
    }
    
    function onRequestFinished(message) {
        // Fallback JSON parser for models that output tool calls as JSON text
        const content = message.content.trim();
        
        let jsonStr = "";
        const jsonCodeBlockRegex = /```json\s*([\s\S]*?)\s*```/;
        const match = content.match(jsonCodeBlockRegex);
        if (match) {
            jsonStr = match[1].trim();
        } else if (content.startsWith("{") && content.endsWith("}")) {
            jsonStr = content;
        } else {
            // Find first '{' and last '}'
            const start = content.indexOf("{");
            const end = content.lastIndexOf("}");
            if (start !== -1 && end !== -1 && end > start) {
                jsonStr = content.substring(start, end + 1);
            }
        }
        
        if (jsonStr) {
            try {
                const parsed = JSON.parse(jsonStr);
                if (parsed && parsed.name && parsed.arguments) {
                    console.log("[AI] Parsed fallback tool call:", parsed.name);
                    
                    // Clear the raw JSON text from chat message so it doesn't show the ugly JSON block
                    message.content = "";
                    message.rawContent = "";
                    
                    // Construct the function call object
                    const functionCallObj = {
                        "name": parsed.name,
                        "args": parsed.arguments
                    };
                    
                    return {
                        finished: true,
                        functionCall: functionCallObj
                    };
                }
            } catch (e) {
                console.log("[AI] Fallback JSON parse failed:", e);
            }
        }
        return { finished: true };
    }
    
    function reset() {
        isReasoning = false;
        toolCallId = "";
        toolCallName = "";
        toolCallArgs = "";
    }

}
