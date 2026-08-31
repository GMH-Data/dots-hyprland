import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.services
import qs.modules.common
import qs.modules.common.widgets

ScrollView {
    id: root
    clip: true
    contentWidth: root.width
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
            color: Appearance.colors.colOnLayer2
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

        RowLayout {
            Layout.fillWidth: true
            visible: Config.options.ai.langchainAgent
            StyledText {
                Layout.fillWidth: true
                font.pixelSize: Appearance.font.pixelSize.small
                text: Translation.tr("Model Name (Click to select)")
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
                    color: Appearance.colors.colOnLayer2
                }
            }
        }

        ComboBox {
            id: modelComboBox
            Layout.fillWidth: true
            model: modelsListModel
            textRole: "modelData"
            enabled: Config.options.ai.langchainAgent
            visible: Config.options.ai.langchainAgent

            onActivated: function(index) {
                var selected = modelsListModel.get(index).modelData;
                if (selected && selected !== "No models found" && selected !== "Ollama not running" && selected !== "Error parsing models") {
                    Config.options.ai.langchainModel = selected;
                    Ai.setModel(Ai.safeModelName(selected));
                }
            }
        }

        ListModel {
            id: modelsListModel
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Appearance.colors.colOutlineVariant
            Layout.topMargin: 10
            Layout.bottomMargin: 10
        }

        // SECTION: Public Agent
        StyledText {
            Layout.fillWidth: true
            font.pixelSize: Appearance.font.pixelSize.large
            font.bold: true
            text: Translation.tr("Public Agent")
            color: Appearance.colors.colOnLayer2
        }

        StyledText {
            Layout.fillWidth: true
            font.pixelSize: Appearance.font.pixelSize.small
            text: Translation.tr("API Endpoint")
            color: Appearance.colors.colSubtext
        }

        MaterialTextField {
            Layout.fillWidth: true
            placeholderText: Translation.tr("e.g. https://openrouter.ai/api/v1/chat/completions")
            text: Config.options.ai.publicEndpoint
            onTextChanged: {
                Config.options.ai.publicEndpoint = text.trim();
            }
        }

        StyledText {
            Layout.fillWidth: true
            font.pixelSize: Appearance.font.pixelSize.small
            text: "API Key"
            color: Appearance.colors.colSubtext
        }

        MaterialTextField {
            Layout.fillWidth: true
            placeholderText: Translation.tr("Paste API Key here")
            text: Ai.apiKeys["public"] ?? ""
            echoMode: TextInput.Password
            onTextChanged: {
                if (text !== (Ai.apiKeys["public"] ?? "")) {
                    KeyringStorage.setNestedField(["apiKeys", "public"], text.trim());
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Appearance.colors.colOutlineVariant
            Layout.topMargin: 10
            Layout.bottomMargin: 10
        }

        // SECTION: Basic Settings
        StyledText {
            Layout.fillWidth: true
            font.pixelSize: Appearance.font.pixelSize.large
            font.bold: true
            text: Translation.tr("Basic Settings")
            color: Appearance.colors.colOnLayer2
        }

        StyledText {
            Layout.fillWidth: true
            font.pixelSize: Appearance.font.pixelSize.small
            text: Translation.tr("System Prompt")
            color: Appearance.colors.colSubtext
        }

        ScrollView {
            id: sysPromptScroll
            Layout.fillWidth: true
            Layout.preferredHeight: 150
            clip: true

            ScrollBar.vertical: ScrollBar {
                parent: sysPromptScroll
                x: sysPromptScroll.mirrored ? 0 : sysPromptScroll.width - width
                y: sysPromptScroll.topPadding
                height: sysPromptScroll.availableHeight
                active: sysPromptScroll.ScrollBar.vertical.active
                contentItem: Rectangle {
                    implicitWidth: 6
                    implicitHeight: 100
                    radius: width / 2
                    color: sysPromptScroll.ScrollBar.vertical.pressed ? Appearance.colors.colPrimary : Appearance.colors.colOutlineVariant
                }
            }

            MaterialTextArea {
                width: sysPromptScroll.width
                placeholderText: Translation.tr("Enter system prompt...")
                text: Config.options.ai.systemPrompt
                onTextChanged: {
                    Config.options.ai.systemPrompt = text;
                }
            }
        }

        StyledText {
            Layout.fillWidth: true
            font.pixelSize: Appearance.font.pixelSize.small
            text: Translation.tr("Output Structure")
            color: Appearance.colors.colSubtext
        }

        ScrollView {
            id: outStructScroll
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            clip: true

            ScrollBar.vertical: ScrollBar {
                parent: outStructScroll
                x: outStructScroll.mirrored ? 0 : outStructScroll.width - width
                y: outStructScroll.topPadding
                height: outStructScroll.availableHeight
                active: outStructScroll.ScrollBar.vertical.active
                contentItem: Rectangle {
                    implicitWidth: 6
                    implicitHeight: 100
                    radius: width / 2
                    color: outStructScroll.ScrollBar.vertical.pressed ? Appearance.colors.colPrimary : Appearance.colors.colOutlineVariant
                }
            }

            MaterialTextArea {
                width: outStructScroll.width
                placeholderText: Translation.tr("e.g. JSON, Markdown, XML...")
                text: Config.options.ai.outputStructure
                onTextChanged: {
                    Config.options.ai.outputStructure = text;
                }
            }
        }

        ConfigSwitch {
            Layout.fillWidth: true
            buttonIcon: "stream"
            text: Translation.tr("Streaming Output")
            checked: Config.options.ai.streaming
            onCheckedChanged: {
                Config.options.ai.streaming = checked;
            }
        }

        ConfigSwitch {
            Layout.fillWidth: true
            buttonIcon: "api"
            text: Translation.tr("Enable MCP Tools")
            checked: Config.options.ai.enableMcp
            onCheckedChanged: {
                Config.options.ai.enableMcp = checked;
            }
        }

        ConfigSwitch {
            Layout.fillWidth: true
            buttonIcon: "psychology"
            text: Translation.tr("Thinking Mode")
            checked: Config.options.ai.thinkingMode
            onCheckedChanged: {
                Config.options.ai.thinkingMode = checked;
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Appearance.colors.colOutlineVariant
            Layout.topMargin: 10
            Layout.bottomMargin: 10
        }

        // SECTION: Advanced Settings
        StyledText {
            Layout.fillWidth: true
            font.pixelSize: Appearance.font.pixelSize.large
            font.bold: true
            text: Translation.tr("Advanced Settings")
            color: Appearance.colors.colOnLayer2
        }

        ConfigSlider {
            Layout.fillWidth: true
            buttonIcon: "device_thermostat"
            text: Translation.tr("Temperature")
            from: 0.0
            to: 2.0
            usePercentTooltip: false
            value: Config.options.ai.temperature
            onValueChanged: {
                Config.options.ai.temperature = value;
            }
        }

        ConfigSlider {
            Layout.fillWidth: true
            buttonIcon: "psychology"
            text: Translation.tr("Top P")
            from: 0.0
            to: 1.0
            usePercentTooltip: false
            value: Config.options.ai.topP
            onValueChanged: {
                Config.options.ai.topP = value;
            }
        }

        ConfigSlider {
            Layout.fillWidth: true
            buttonIcon: "filter_list"
            text: Translation.tr("Top K")
            from: 0.0
            to: 100.0
            usePercentTooltip: false
            value: Config.options.ai.topK
            onValueChanged: {
                Config.options.ai.topK = Math.round(value);
            }
        }
    }

    Timer {
        id: ollamaRetryTimer
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            if (modelsListModel.count === 0 || (modelsListModel.count > 0 && modelsListModel.get(0).modelData === "Ollama not running")) {
                fetchModels();
            } else {
                running = false;
            }
        }
    }

    function fetchModels() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "http://localhost:11434/api/tags", true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                modelsListModel.clear();
                if (xhr.status === 200) {
                    try {
                        var resp = JSON.parse(xhr.responseText);
                        if (resp.models && resp.models.length > 0) {
                            var currentModelId = Ai.currentModelId;
                            var foundIndex = -1;
                            for (var i = 0; i < resp.models.length; i++) {
                                modelsListModel.append({ "modelData": resp.models[i].name });
                                if (Ai.safeModelName(resp.models[i].name) === currentModelId || resp.models[i].name === Config.options.ai.langchainModel) {
                                    foundIndex = i;
                                }
                            }
                            if (foundIndex !== -1) {
                                modelComboBox.currentIndex = foundIndex;
                            } else {
                                Config.options.ai.langchainModel = resp.models[0].name;
                                modelComboBox.currentIndex = 0;
                                Ai.setModel(Ai.safeModelName(resp.models[0].name), false, true);
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
