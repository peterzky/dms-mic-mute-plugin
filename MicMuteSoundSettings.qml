import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Modules.Plugins

PluginSettings {
    id: root

    ToggleSetting {
        Layout.fillWidth: true
        settingKey: "enabled"
        label: I18n.tr("Enable Mic Mute Sound")
        description: I18n.tr("Play audio feedback when microphone is muted or unmuted")
        defaultValue: true
    }

    StyledText {
        Layout.fillWidth: true
        text: I18n.tr("Sound files are located in the plugin's sounds/ directory. Replace mic-muted.wav and mic-unmute.wav with your own sounds.")
        font.pixelSize: Theme.fontSizeSmall
        wrapMode: Text.WordWrap
    }
}