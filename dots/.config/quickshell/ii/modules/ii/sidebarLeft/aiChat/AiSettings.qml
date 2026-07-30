import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ScrollView {
    id: scrollView
    clip: true
    contentWidth: scrollView.width
    topPadding: 15
    bottomPadding: 15

    ColumnLayout {
        width: scrollView.width - 20
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
            Layout.fillWidth: true
            placeholderText: "llama3.2:3b"
            text: Config.options.ai.langchainModel
            enabled: Config.options.ai.langchainAgent
            visible: Config.options.ai.langchainAgent
            onTextChanged: {
                Config.options.ai.langchainModel = text;
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
}
