import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root
    anchors.fill: parent

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 10

        MaterialSymbol {
            Layout.alignment: Qt.AlignHCenter
            text: "hub"
            iconSize: 48
            color: Appearance.colors.colSubtext
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: Appearance.font.pixelSize.large
            font.bold: true
            text: "Model Context Protocol (MCP)"
            color: Appearance.colors.colText
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: Appearance.font.pixelSize.normal
            text: Translation.tr("Connect your AI to external tools and data sources.")
            color: Appearance.colors.colSubtext
        }
    }
}
