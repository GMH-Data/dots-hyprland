import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.ii.sidebarRight.quickToggles.androidStyle

AndroidQuickToggleButton {
    id: root

    // Display mode: 0=PC Only, 1=Duplicate, 2=Extend, 3=Second Only
    property int displayMode: 0
    property bool hdmiConnected: false

    readonly property var modeNames: ["PC Only", "Duplicate", "Extend", "2nd Screen"]
    readonly property var modeIcons: ["desktop_windows", "cast", "dual_screen", "tv"]

    name: "Display"
    buttonIcon: modeIcons[displayMode]
    toggled: displayMode > 0
    statusText: hdmiConnected ? modeNames[displayMode] : "No Display"
    tooltipText: hdmiConnected
        ? `${modeNames[displayMode]} - Click to switch mode`
        : "No external display connected"

    // Poll HDMI + monitor status
    Process {
        id: checkHdmiProc
        command: ["sh", "-c",
            "STATUS=$(cat /sys/class/drm/card1-HDMI-A-1/status 2>/dev/null || echo disconnected); " +
            "MONITORS=$(hyprctl monitors all -j 2>/dev/null || echo '[]'); " +
            "echo \"$STATUS|$MONITORS\""
        ]
        stdout: SplitParser {
            onRead: line => {
                let sepIdx = line.indexOf("|");
                if (sepIdx < 0) return;
                let status = line.substring(0, sepIdx).trim();
                let monitorsJson = line.substring(sepIdx + 1);

                root.hdmiConnected = (status === "connected");

                if (!root.hdmiConnected) {
                    root.displayMode = 0;
                    return;
                }

                try {
                    let monitors = JSON.parse(monitorsJson);
                    let edp = null;
                    let hdmi = null;
                    for (let i = 0; i < monitors.length; i++) {
                        if (monitors[i].name === "eDP-1") edp = monitors[i];
                        if (monitors[i].name === "HDMI-A-1") hdmi = monitors[i];
                    }

                    if (!hdmi || hdmi.disabled) {
                        root.displayMode = 0; // PC Only
                    } else if (hdmi.mirrorOf === "eDP-1") {
                        root.displayMode = 1; // Duplicate
                    } else if (!edp || edp.disabled) {
                        root.displayMode = 3; // Second Only
                    } else {
                        root.displayMode = 2; // Extend
                    }
                } catch(e) {
                    console.log("Display mode parse error:", e);
                }
            }
        }
    }

    Timer {
        id: hdmiPollTimer
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            checkHdmiProc.running = true;
        }
    }

    mainAction: () => {
        if (!hdmiConnected) return;
        let nextMode = (displayMode + 1) % 4;
        switch (nextMode) {
        case 0: // PC Only - disable HDMI, enable eDP
            Quickshell.execDetached(["hyprctl", "keyword", "monitor", "eDP-1,preferred,auto,1"]);
            Quickshell.execDetached(["hyprctl", "keyword", "monitor", "HDMI-A-1,disable"]);
            break;
        case 1: // Duplicate - mirror eDP to HDMI
            Quickshell.execDetached(["hyprctl", "keyword", "monitor", "eDP-1,preferred,auto,1"]);
            Quickshell.execDetached(["hyprctl", "keyword", "monitor", "HDMI-A-1,preferred,auto,1,mirror,eDP-1"]);
            break;
        case 2: // Extend - both side by side
            Quickshell.execDetached(["hyprctl", "keyword", "monitor", "eDP-1,preferred,0x0,1"]);
            Quickshell.execDetached(["hyprctl", "keyword", "monitor", "HDMI-A-1,preferred,1920x0,1"]);
            break;
        case 3: // Second Only - disable eDP, enable HDMI
            Quickshell.execDetached(["hyprctl", "keyword", "monitor", "HDMI-A-1,preferred,auto,1"]);
            Quickshell.execDetached(["hyprctl", "keyword", "monitor", "eDP-1,disable"]);
            break;
        }
        root.displayMode = nextMode;
    }
}
