import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.ii.sidebarRight.quickToggles.androidStyle

AndroidQuickToggleButton {
    id: root

    property bool isManual: !cpuAuto || !gpuAuto
    property bool cpuAuto: true
    property bool gpuAuto: true
    property int cpuActualSpeed: 0
    property int gpuActualSpeed: 0

    name: "Fan Speed"
    buttonIcon: "toys"
    toggled: isManual
    statusText: isManual ? `${cpuActualSpeed}% / ${gpuActualSpeed}%` : "Auto"
    tooltipText: isManual 
        ? `Manual Mode (CPU: ${cpuActualSpeed}%, GPU: ${gpuActualSpeed}%) - Click to set Auto`
        : `Auto Mode (CPU: ${cpuActualSpeed}%, GPU: ${gpuActualSpeed}%) - Click to set Max`

    Process {
        id: getFanStatusProc
        command: ["/home/gmh/.config/quickshell/ii/scripts/hyprland/get_fan_status.sh"]
        stdout: SplitParser {
            onRead: line => {
                let parts = line.trim().split(",");
                if (parts.length >= 4) {
                    root.cpuAuto = parts[1] === "true" || parts[1] === "1";
                    root.gpuAuto = parts[3] === "true" || parts[3] === "1";
                    if (parts.length >= 6) {
                        root.cpuActualSpeed = parseInt(parts[4]);
                        root.gpuActualSpeed = parseInt(parts[5]);
                    }
                }
            }
        }
    }

    Timer {
        id: fanPollTimer
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            getFanStatusProc.running = true;
        }
    }

    mainAction: () => {
        if (isManual) {
            Quickshell.execDetached(["sh", "-c", "echo '2312' | sudo -S /home/gmh/.config/quickshell/ii/scripts/hyprland/fan_control.py set both auto"]);
            root.cpuAuto = true;
            root.gpuAuto = true;
        } else {
            Quickshell.execDetached(["sh", "-c", "echo '2312' | sudo -S /home/gmh/.config/quickshell/ii/scripts/hyprland/fan_control.py set both 80"]);
            root.cpuAuto = false;
            root.gpuAuto = false;
        }
    }
}
