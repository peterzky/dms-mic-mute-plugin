import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "micMuteSound"

    ToggleSetting {
        Layout.fillWidth: true
        settingKey: "enabled"
        label: I18n.tr("Enable Mic Mute Sound")
        description: I18n.tr("Play audio feedback when microphone is muted or unmuted")
        defaultValue: true
    }

    SliderSetting {
        Layout.fillWidth: true
        settingKey: "volume"
        label: I18n.tr("Volume")
        description: I18n.tr("Volume level for mute/unmute sounds")
        defaultValue: 100
        minimum: 0
        maximum: 100
        unit: "%"
        leftIcon: "volume_down"
        rightIcon: "volume_up"
    }

    StyledText {
        Layout.fillWidth: true
        text: I18n.tr("Sound files are located in the plugin's sounds/ directory. Replace mic-muted.mp3 and mic-unmute.mp3 with your own sounds.")
        font.pixelSize: Theme.fontSizeSmall
        wrapMode: Text.WordWrap
    }
}