import Quickshell
import Quickshell.Io
import QtQuick
import QtCore
import qs.Bar
import qs.Bar.Modules
import qs.Settings

Scope {
    id: root

    function updateVolume(vol) {
        volume = vol;
        if (defaultAudioSink && defaultAudioSink.audio) {
            defaultAudioSink.audio.volume = vol / 100;
        }
    }

    Component.onCompleted: {
        Quickshell.shell = root;
    }

    Bar {
        id: bar
        shell: root
    }
}
