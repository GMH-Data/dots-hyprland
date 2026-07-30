import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.ii.sidebarLeft.aiChat
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Item {
    id: root

    property var tabButtonList: [
        {"icon": "forum", "name": Translation.tr("Chat")},
        {"icon": "hub", "name": Translation.tr("MCP")},
        {"icon": "database", "name": Translation.tr("RAG")},
        {"icon": "settings", "name": Translation.tr("Setting")}
    ]

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        Toolbar {
            Layout.alignment: Qt.AlignHCenter
            enableShadow: false
            ToolbarTabBar {
                id: tabBar
                Layout.alignment: Qt.AlignHCenter
                tabButtonList: root.tabButtonList
                currentIndex: swipeView.currentIndex
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Appearance.rounding.normal
            color: Appearance.colors.colLayer2

            SwipeView {
                id: swipeView
                anchors.fill: parent
                spacing: 10
                currentIndex: tabBar.currentIndex
                clip: true
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: swipeView.width
                        height: swipeView.height
                        radius: Appearance.rounding.small
                    }
                }

                contentChildren: [
                    aiChatComponent.createObject(),
                    aiMcpComponent.createObject(),
                    aiRagComponent.createObject(),
                    aiSettingsComponent.createObject()
                ]
            }
        }
    }

    Component {
        id: aiChatComponent
        AiChat {}
    }
    Component {
        id: aiMcpComponent
        AiMcp {}
    }
    Component {
        id: aiRagComponent
        AiRag {}
    }
    Component {
        id: aiSettingsComponent
        AiSettings {}
    }
}
