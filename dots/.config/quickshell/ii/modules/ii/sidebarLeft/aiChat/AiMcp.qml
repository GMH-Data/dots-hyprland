import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root

    ListModel {
        id: mcpModel
    }

    Process {
        id: readMcpConfigProc
        command: ["python3", "-c", "import json, os; path='/home/gmh/.config/quickshell/ii/mcp_servers.json'; f=open(path) if os.path.exists(path) else None; data=json.load(f) if f else {}; servers=[{'name': k, 'command': v.get('command',''), 'args': ' '.join(v.get('args',[]))} for k,v in data.get('mcpServers', {}).items()] if data else []; print(json.dumps(servers))"]
        stdout: SplitParser {
            onRead: line => {
                try {
                    let list = JSON.parse(line.trim());
                    mcpModel.clear();
                    for (let i = 0; i < list.length; i++) {
                        mcpModel.append(list[i]);
                    }
                } catch(e) {
                    console.log("Error parsing MCP servers:", e);
                }
            }
        }
    }

    function loadMcpServers() {
        readMcpConfigProc.running = true;
    }

    Component.onCompleted: {
        loadMcpServers();
    }

    // Refresh model when returning to tab
    onVisibleChanged: {
        if (visible) {
            loadMcpServers();
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // Header section
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            MaterialSymbol {
                Layout.alignment: Qt.AlignHCenter
                text: "hub"
                iconSize: 40
                color: Appearance.colors.colPrimary
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: Appearance.font.pixelSize.large
                font.bold: true
                text: "Model Context Protocol (MCP)"
                color: Appearance.colors.colOnLayer2
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                font.pixelSize: Appearance.font.pixelSize.small
                text: Translation.tr("Connect your AI to external tools and data sources.")
                color: Appearance.colors.colSubtext
            }
        }

        // List of active servers
        StyledText {
            Layout.fillWidth: true
            font.pixelSize: Appearance.font.pixelSize.normal
            font.bold: true
            text: Translation.tr("Active MCP Servers:")
            color: Appearance.colors.colOnLayer2
            visible: mcpModel.count > 0
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: mcpModel
            spacing: 8

            delegate: Rectangle {
                width: listView.width
                height: 60
                color: Appearance.colors.colLayer2
                radius: Appearance.rounding.small
                border.color: Appearance.colors.colOutlineVariant
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    MaterialSymbol {
                        text: "dns"
                        iconSize: 24
                        color: Appearance.colors.colPrimary
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        StyledText {
                            font.bold: true
                            font.pixelSize: Appearance.font.pixelSize.normal
                            text: model.name
                            color: Appearance.colors.colOnLayer2
                        }

                        StyledText {
                            font.pixelSize: Appearance.font.pixelSize.small
                            text: model.command + " " + model.args
                            color: Appearance.colors.colSubtext
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }

        // Add MCP button
        Rectangle {
            id: addButton
            Layout.fillWidth: true
            height: 44
            color: Appearance.colors.colPrimary
            radius: Appearance.rounding.normal

            property bool hovered: mouseArea.containsMouse

            opacity: hovered ? 0.9 : 1.0
            Behavior on opacity { NumberAnimation { duration: 150 } }

            RowLayout {
                anchors.centerIn: parent
                spacing: 8

                MaterialSymbol {
                    text: "add"
                    iconSize: 18
                    color: Appearance.colors.colOnPrimary
                }

                StyledText {
                    font.bold: true
                    font.pixelSize: Appearance.font.pixelSize.normal
                    text: Translation.tr("Thêm MCP Server")
                    color: Appearance.colors.colOnPrimary
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Qt.openUrlExternally("file:///home/gmh/.config/quickshell/ii/mcp_servers.json");
                }
            }
        }
    }
}
