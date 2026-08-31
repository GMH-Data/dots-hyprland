import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

import qs.services

Item {
    id: root

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 10

        MaterialSymbol {
            Layout.alignment: Qt.AlignHCenter
            text: "database"
            iconSize: 48
            color: Appearance.colors.colSubtext
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: Appearance.font.pixelSize.large
            font.bold: true
            text: "Retrieval-Augmented Generation (RAG)"
            color: Appearance.colors.colOnLayer2
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: Appearance.font.pixelSize.normal
            text: Translation.tr("Query your local documentation and knowledge base.")
            color: Appearance.colors.colSubtext
        }
    }
}
