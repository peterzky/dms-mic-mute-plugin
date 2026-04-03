import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Modules.Plugins

PluginComponent {
    id: root

    // Track last known mute state to detect transitions
    property bool lastMutedState: AudioService.source?.audio?.muted ?? false

    property int volume: pluginData.volume ?? 100

    // Debounce timer to prevent rapid state changes
    property bool pendingPlay: false
    property bool pendingMutedState: false

    // Resolve sound file paths relative to this plugin directory
    property string muteSoundPath: Qt.resolvedUrl("sounds/mic-muted.mp3")
    property string unmuteSoundPath: Qt.resolvedUrl("sounds/mic-unmute.mp3")

    // Debounce timer (100ms)
    Timer {
        id: debounceTimer
        interval: 100
        repeat: false
        onTriggered: {
            if (pendingPlay) {
                playSoundForState(pendingMutedState)
                pendingPlay = false
            }
        }
    }

    // Component for creating disposable sound processes
    Component {
        id: soundProcessComponent

        Process {
            property string soundPath: ""

            command: ["pw-play", "--volume", (volume / 100).toString(), soundPath]
            running: true

            onExited: (exitCode, exitStatus) => {
                if (exitCode !== 0) {
                    console.warn("MicMuteSound: pw-play exited with code", exitCode, "for", soundPath)
                }
                destroy()
            }
        }
    }

    // Monitor IPC-triggered mute changes (dms ipc call audio micmute)
    Connections {
        target: AudioService
        function onMicMuteChanged() {
            handleMuteStateChange()
        }
    }

    // Monitor hardware/external mute changes (mute button on headset, other apps)
    Connections {
        target: AudioService.source?.audio ?? null
        enabled: AudioService.source?.audio !== null
        function onMutedChanged() {
            handleMuteStateChange()
        }
    }

    function handleMuteStateChange() {
        const currentMuted = AudioService.source?.audio?.muted ?? false

        console.info("MicMuteSound: mute state change detected, current:", currentMuted, "last:", lastMutedState)

        // Skip if state hasn't actually changed
        if (currentMuted === lastMutedState) {
            return
        }

        // Debounce: queue the sound play
        pendingPlay = true
        pendingMutedState = currentMuted
        debounceTimer.restart()

        lastMutedState = currentMuted
    }

    function playSoundForState(muted) {
        const soundPath = muted ? muteSoundPath : unmuteSoundPath

        // Convert Qt.resolvedUrl to file path for pw-play
        const filePath = soundPath.toString().replace("file://", "")

        console.info("MicMuteSound: playing", filePath)

        // Create new process instance for each sound play
        soundProcessComponent.createObject(root, { soundPath: filePath })
    }

    Component.onCompleted: {
        console.info("MicMuteSound: Plugin started, monitoring mic mute state")
        // Initialize lastMutedState
        if (AudioService.source?.audio) {
            lastMutedState = AudioService.source.audio.muted
        }
    }

    Component.onDestruction: {
        console.info("MicMuteSound: Plugin stopped")
    }
}
