import QtQuick
import QtMultimedia
import Quickshell
import qs.Common
import qs.Services
import qs.Modules.Plugins

PluginComponent {
    id: root

    property bool lastMutedState: AudioService.source?.audio?.muted ?? false
    property int volume: pluginData.volume ?? 100

    // MediaPlayer for mute sound
    MediaPlayer {
        id: muteSoundPlayer
        source: Qt.resolvedUrl("sounds/mic-muted.mp3")
        audioOutput: AudioOutput {
            device: AudioService.mediaDevices?.defaultAudioOutput ?? null
            volume: root.volume / 100
        }

        onErrorOccurred: (error, errorString) => {
            console.warn("MicMuteSound: Mute sound error:", errorString)
        }

        function replay() {
            if (status === MediaPlayer.Loaded) {
                stop()
                position = 0
                play()
            }
        }
    }

    // MediaPlayer for unmute sound
    MediaPlayer {
        id: unmuteSoundPlayer
        source: Qt.resolvedUrl("sounds/mic-unmute.mp3")
        audioOutput: AudioOutput {
            device: AudioService.mediaDevices?.defaultAudioOutput ?? null
            volume: root.volume / 100
        }

        onErrorOccurred: (error, errorString) => {
            console.warn("MicMuteSound: Unmute sound error:", errorString)
        }

        function replay() {
            if (status === MediaPlayer.Loaded) {
                stop()
                position = 0
                play()
            }
        }
    }

    // Debounce timer to prevent rapid state changes
    property bool pendingPlay: false
    property bool pendingMutedState: false

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

        if (currentMuted === lastMutedState) {
            return
        }

        pendingPlay = true
        pendingMutedState = currentMuted
        debounceTimer.restart()

        lastMutedState = currentMuted
    }

    function playSoundForState(muted) {
        const player = muted ? muteSoundPlayer : unmuteSoundPlayer
        console.info("MicMuteSound: playing", muted ? "mute" : "unmute", "sound")
        player.replay()
    }

    Component.onCompleted: {
        console.info("MicMuteSound: Plugin started, monitoring mic mute state")
        if (AudioService.source?.audio) {
            lastMutedState = AudioService.source.audio.muted
        }
    }

    Component.onDestruction: {
        console.info("MicMuteSound: Plugin stopped")
    }
}