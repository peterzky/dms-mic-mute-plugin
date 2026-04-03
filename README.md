# Mic Mute Sound Plugin

Plays distinct audio feedback when the microphone is muted or unmuted.

## Features

- **Mute sound**: Lower-pitched click (400Hz) when mic is muted
- **Unmute sound**: Higher-pitched click (800Hz) when mic is unmuted
- Detects both IPC-triggered toggles (`dms ipc call audio micmute`) and hardware mute buttons
- 100ms debounce to handle rapid state changes

## Installation

Install via the DMS plugin browser or place this directory in your plugins folder.

## Usage

1. Enable the plugin in Settings → Plugins → Mic Mute Sound
2. Toggle your microphone mute using any method:
   - `dms ipc call audio micmute`
   - Hardware mute button on headset
   - Any other application that toggles mic mute
3. Hear the corresponding sound feedback

## Custom Sounds

Replace the sound files in `sounds/` directory:
- `mic-muted.wav` - Sound played when mic is muted
- `mic-unmute.wav` - Sound played when mic is unmuted

Sound files must be in a format supported by `pw-play` (wav, ogg, flac, etc.).

## Requirements

- `pw-play` (part of PipeWire)

## License

MIT