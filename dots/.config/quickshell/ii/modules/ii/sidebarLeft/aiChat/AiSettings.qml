import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ScrollView {
    id: root
    clip: true
    contentWidth: scrollView.width
    topPadding: 15
    bottomPadding: 15

    ColumnLayout {
        width: root.width - 20
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 15

        // SECTION: Local Agent
        StyledText {
            Layout.fillWidth: true
            font.pixelSize: Appearance.font.pixelSize.large
            font.bold: true
            text: Translation.tr("Local LangChain Agent")
            color: Appearance.colors.colText
        }

        ConfigSwitch {
            Layout.fillWidth: true
            buttonIcon: "smart_toy"
            text: Translation.tr("Use Local LangChain Agent")
            checked: Config.options.ai.langchainAgent
            onCheckedChanged: {
                Config.options.ai.langchainAgent = checked;
            }
        }

        StyledText {
            Layout.fillWidth: true
            font.pixelSize: Appearance.font.pixelSize.small
            text: Translation.tr("API Endpoint URL")
            color: Appearance.colors.colSubtext
            visible: Config.options.ai.langchainAgent
        }

        MaterialTextField {
            Layout.fillWidth: true
            placeholderText: "http://localhost:8000/v1/chat/completions"
            text: Config.options.ai.langchainEndpoint
            enabled: Config.options.ai.langchainAgent
            visible: Config.options.ai.langchainAgent
            onTextChanged: {
                Config.options.ai.langchainEndpoint = text;
            }
        }

        StyledText {
            Layout.fillWidth: true
            font.pixelSize: Appearance.font.pixelSize.small
            text: Translation.tr("Model Name")
            color: Appearance.colors.colSubtext
            visible: Config.options.ai.langchainAgent
        }

        MaterialTextField {
            id: modelField
            Layout.fillWidth: true
            placeholderText: "llama3.2:3b"
            text: Config.options.ai.langchainModel
            enabled: Config.options.ai.langchainAgent
            visible: Config.options.ai.langchainAgent
            onTextChanged: {
                Config.options.ai.langchainModel = text;
            }
        }

        RowLayout {
            Layout.fillWidth: true
            visible: Config.options.ai.langchainAgent
            StyledText {
                Layout.fillWidth: true
                font.pixelSize: Appearance.font.pixelSize.small
                text: Translation.tr("Available Local Models (Click to select)")
                color: Appearance.colors.colSubtext
            }
            
            MouseArea {
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                cursorShape: Qt.PointingHandCursor
                onClicked: root.fetchModels()
                StyledText {
                    anchors.centerIn: parent
                    font.family: "Material Symbols Rounded"
                    text: "refresh"
                    color: Appearance.colors.colText
                }
            }
        }

        ListModel {
            id: modelsListModel
        }

        Repeater {
            model: modelsListModel
            delegate: Rectangle {
                Layout.fillWidth: true
                height: 35
                color: Appearance.colors.colSurface
                radius: 5
                border.color: Appearance.colors.colOutline
                border.width: 1
                visible: Config.options.ai.langchainAgent

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 5
                    StyledText {
                        Layout.fillWidth: true
                        text: modelData
                        color: Appearance.colors.colText
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        modelField.text = modelData;
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Appearance.colors.colOutlineVariant
        }

        // SECTION: Public API Keys
        StyledText {
            Layout.fillWidth: true
            font.pixelSize: Appearance.font.pixelSize.large
            font.bold: true
            text: Translation.tr("Public API Keys")
            color: Appearance.colors.colText
        }

        // Gemini Key
        StyledText {
            Layout.fillWidth: true
            font.pixelSize: Appearance.font.pixelSize.small
            text: "Google Gemini API Key"
            color: Appearance.colors.colSubtext
        }

        MaterialTextField {
            Layout.fillWidth: true
            placeholderText: Translation.tr("Paste Gemini API Key here")
            text: Ai.apiKeys["gemini"] ?? ""
            echoMode: TextInput.Password
            onTextChanged: {
                if (text !== (Ai.apiKeys["gemini"] ?? "")) {
                    KeyringStorage.setNestedField(["apiKeys", "gemini"], text.trim());
                }
            }
        }

        // OpenRouter Key
        StyledText {
            Layout.fillWidth: true
            font.pixelSize: Appearance.font.pixelSize.small
            text: "OpenRouter API Key"
            color: Appearance.colors.colSubtext
        }

        MaterialTextField {
            Layout.fillWidth: true
            placeholderText: Translation.tr("Paste OpenRouter API Key here")
            text: Ai.apiKeys["openrouter"] ?? ""
            echoMode: TextInput.Password
            onTextChanged: {
                if (text !== (Ai.apiKeys["openrouter"] ?? "")) {
                    KeyringStorage.setNestedField(["apiKeys", "openrouter"], text.trim());
                }
            }
        }

        // Mistral Key
        StyledText {
            Layout.fillWidth: true
            font.pixelSize: Appearance.font.pixelSize.small
            text: "Mistral API Key"
            color: Appearance.colors.colSubtext
        }

        MaterialTextField {
            Layout.fillWidth: true
            placeholderText: Translation.tr("Paste Mistral API Key here")
            text: Ai.apiKeys["mistral"] ?? ""
            echoMode: TextInput.Password
            onTextChanged: {
                if (text !== (Ai.apiKeys["mistral"] ?? "")) {
                    KeyringStorage.setNestedField(["apiKeys", "mistral"], text.trim());
                }
            }
        }
    }

    function fetchModels() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "http://localhost:11434/api/tags");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                modelsListModel.clear();
                if (xhr.status === 200) {
                    try {
                        var resp = JSON.parse(xhr.responseText);
                        if (resp.models && resp.models.length > 0) {
                            for (var i = 0; i < resp.models.length; i++) {
                                modelsListModel.append({ "modelData": resp.models[i].name });
                            }
                        } else {
                            modelsListModel.append({ "modelData": "No models found" });
                        }
                    } catch(e) {
                        modelsListModel.append({ "modelData": "Error parsing models" });
                    }
                } else {
                    modelsListModel.append({ "modelData": "Ollama not running" });
                }
            }
        }
        xhr.send();
    }

    Component.onCompleted: fetchModels()
}
