# MediaPlayer Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace Process-based pw-play sound playback with native QtMultimedia MediaPlayer.

**Architecture:** Two persistent MediaPlayer instances with reactive volume binding and device routing via AudioService.mediaDevices.

**Tech Stack:** QtQuick, QtMultimedia (MediaPlayer, AudioOutput), DankMaterialShell plugin system

---

## Files

| File | Action | Purpose |
|------|--------|---------|
| `MicMuteSound.qml` | Modify | Replace Process with MediaPlayer |
| `README.md` | Modify | Update requirements, remove pw-play |

---

### Task 1: Refactor MicMuteSound.qml

**Files:**
- Modify: `MicMuteSound.qml`

- [ ] **Step 1: Replace imports and remove Process component**

Replace the entire file content:

```qml
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
```

- [ ] **Step 2: Commit MicMuteSound.qml changes**

```bash
git add MicMuteSound.qml
git commit -m "refactor: replace pw-play Process with QtMultimedia MediaPlayer

- Remove external pw-play dependency
- Add MediaPlayer + AudioOutput for mute/unmute sounds
- Enable device routing via AudioService.mediaDevices
- Reactive volume binding to plugin setting

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

### Task 2: Update README.md

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Update requirements and features section**

Replace lines 12 and 39-44:

**Remove line 12:**
```
- Disposable sound processes (non-blocking playback)
```

**Replace lines 39-44:**
```markdown
Sound files must be in a format supported by QtMultimedia MediaPlayer (mp3, wav, ogg, flac, etc.).

## Requirements

- DankMaterialShell (QtMultimedia support included)
```

Full updated README.md:

```markdown
# Mic Mute Sound Plugin

Plays distinct audio feedback when the microphone is muted or unmuted.

## Features

- **Mute sound**: Audio feedback when mic is muted
- **Unmute sound**: Audio feedback when mic is unmuted
- **Volume control**: Adjustable volume (0-100%) for sound effects
- Detects both IPC-triggered toggles (`dms ipc call audio micmute`) and hardware mute buttons
- 100ms debounce to handle rapid state changes

## Installation

Install via the DMS plugin browser or place this directory in your plugins folder.

## Configuration

In Settings → Plugins → Mic Mute Sound:

- **Enable Mic Mute Sound**: Toggle the plugin on/off
- **Volume**: Adjust the volume level for mute/unmute sounds (0-100%)

## Usage

1. Enable the plugin in Settings → Plugins → Mic Mute Sound
2. Toggle your microphone mute using any method:
   - `dms ipc call audio micmute`
   - Hardware mute button on headset
   - Any other application that toggles mic mute
3. Hear the corresponding sound feedback

## Custom Sounds

Replace the sound files in the `sounds/` directory:
- `mic-muted.mp3` - Sound played when mic is muted
- `mic-unmute.mp3` - Sound played when mic is unmuted

Sound files must be in a format supported by QtMultimedia MediaPlayer (mp3, wav, ogg, flac, etc.).

## Requirements

- DankMaterialShell (QtMultimedia support included)

## License

MIT
```

- [ ] **Step 2: Commit README.md changes**

```bash
git add README.md
git commit -m "docs: update requirements, remove pw-play dependency

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

### Task 3: Manual Testing Verification

- [ ] **Step 1: Reload DMS and verify plugin loads**

Run: `dms ipc call shell reload`
Expected: Plugin loads without errors in logs

- [ ] **Step 2: Test mute/unmute sound playback**

Toggle mic mute via `dms ipc call audio micmute`
Expected: Sound plays on mute, different sound on unmute

- [ ] **Step 3: Test volume control**

Set volume to 50% in plugin settings, toggle mute
Expected: Sound plays at lower volume

- [ ] **Step 4: Push changes**

```bash
git push origin main
```