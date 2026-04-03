# MicMuteSound MediaPlayer Refactor Design

**Date:** 2026-04-04
**Status:** Approved

## Summary

Replace Process-based `pw-play` sound playback with native QtMultimedia `MediaPlayer` + `AudioOutput`. This removes external dependency, enables device routing, and provides reactive volume binding.

## Current Implementation

- Spawns `pw-play` process via `Process` component for each sound event
- External dependency (pw-play must be installed)
- Volume passed via `--volume` flag (0.0-1.0)
- Process destroyed after playback completes
- No device routing - uses system default

## Proposed Implementation

### Architecture

Two persistent `MediaPlayer` instances (mute/unmute) created at plugin startup. Volume bound reactively to plugin setting. Device routing via `AudioService.mediaDevices.defaultAudioOutput`.

### Components

**MediaPlayer instances:**
- `muteSoundPlayer` - plays `sounds/mic-muted.mp3`
- `unmuteSoundPlayer` - plays `sounds/mic-unmute.mp3`

**AudioOutput configuration:**
- `device`: `AudioService.mediaDevices?.defaultAudioOutput ?? null` (follows system default output, falls back if mediaDevices unavailable)
- `volume`: `root.volume / 100` (reactive binding to plugin setting, 0-100 → 0.0-1.0)

**replay() helper function:**
- Stops player, resets position to 0, plays
- Only plays if `status === MediaPlayer.Loaded`

### Error Handling

- `onErrorOccurred` signal handler logs warning to console
- `replay()` checks `status` before playing

### Changes to Existing Code

**Removed:**
- `soundProcessComponent` (Process-based component)
- Path conversion (`toString().replace("file://", "")`)
- Process exit code handling

**Modified:**
- `playSoundForState()` - calls `player.replay()` instead of spawning process

**Unchanged:**
- Debounce timer (100ms)
- Connections to AudioService (IPC and hardware mute detection)
- Volume setting slider in settings UI

## File Changes

| File | Change |
|------|--------|
| `MicMuteSound.qml` | Replace Process with MediaPlayer |
| `MicMuteSoundSettings.qml` | No changes |
| `plugin.json` | No changes |
| `README.md` | Update requirements section (remove pw-play) |

## Benefits

| Aspect | Before | After |
|--------|--------|-------|
| Dependency | `pw-play` required | Native QtMultimedia |
| Device routing | None | Follows default output |
| Volume | Independent | Reactive binding |
| Process overhead | Spawn/destroy each play | Persistent players |
| Error handling | Process exit code | MediaPlayer error signal |

## Risks

- **QtMultimedia availability**: DankMaterialShell already uses QtMultimedia for system sounds, so this is not a new dependency
- **MediaPlayer loading**: Sounds loaded asynchronously; first play may have slight delay. Mitigation: players created at startup, sounds preload

## Testing

1. Enable plugin, toggle mic mute - verify sound plays
2. Adjust volume slider, toggle mute - verify volume change
3. Change system default audio output - verify sound follows new device
4. Remove sound files - verify error logged gracefully
5. Rapid mute/unmute toggles - verify debounce prevents overlap