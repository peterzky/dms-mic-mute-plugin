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

    MediaDevices {
        id: mediaDevices
    }

    Connections {
        target: mediaDevices
        function onDefaultAudioOutputChanged() {
            muteAudioOutput.device = mediaDevices.defaultAudioOutput
            unmuteAudioOutput.device = mediaDevices.defaultAudioOutput
        }
    }

    MediaPlayer {
        id: muteSoundPlayer
        source: Qt.resolvedUrl("sounds/mic-muted.mp3")
        audioOutput: AudioOutput {
            id: muteAudioOutput
            volume: root.volume / 100
        }
        onErrorOccurred: (error, errorString) => {
            console.warn("MicMuteSound: Mute sound error:", error, errorString)
        }
    }

    MediaPlayer {
        id: unmuteSoundPlayer
        source: Qt.resolvedUrl("sounds/mic-unmute.mp3")
        audioOutput: AudioOutput {
            id: unmuteAudioOutput
            volume: root.volume / 100
        }
        onErrorOccurred: (error, errorString) => {
            console.warn("MicMuteSound: Unmute sound error:", error, errorString)
        }
    }

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

    Connections {
        target: AudioService
        function onMicMuteChanged() {
            handleMuteStateChange()
        }
    }

    Connections {
        target: AudioService.source?.audio ?? null
        enabled: AudioService.source?.audio !== null
        function onMutedChanged() {
            handleMuteStateChange()
        }
    }

    function handleMuteStateChange() {
        const currentMuted = AudioService.source?.audio?.muted ?? false

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
        player.play()
    }

    Component.onCompleted: {
        console.info("MicMuteSound: Plugin started")
        if (AudioService.source?.audio) {
            lastMutedState = AudioService.source.audio.muted
        }
        // Set initial audio output device
        muteAudioOutput.device = mediaDevices.defaultAudioOutput
        unmuteAudioOutput.device = mediaDevices.defaultAudioOutput
    }
}