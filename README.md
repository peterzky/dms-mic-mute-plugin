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