import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Modules.Audio
import qs.Commons
import qs.Services
import qs.Widgets

RowLayout {
  id: root

  property ShellScreen screen
  property real scaling: 1.0
  readonly property real minWidth: 160
  readonly property real maxWidth: 400

  Layout.alignment: Qt.AlignVCenter
  spacing: Style.marginS * scaling
  visible: MediaService.currentPlayer !== null && MediaService.canPlay
  Layout.preferredWidth: MediaService.currentPlayer !== null && MediaService.canPlay ? implicitWidth : 0

  function getTitle() {
    return MediaService.trackTitle + (MediaService.trackArtist !== "" ? ` - ${MediaService.trackArtist}` : "")
  }

  //  A hidden text element to safely measure the full title width
  NText {
    id: fullTitleMetrics
    visible: false
    text: titleText.text
    font: titleText.font
  }

  Rectangle {
    id: mediaMini

    Layout.preferredWidth: rowLayout.implicitWidth + Style.marginM * 2 * scaling
    Layout.preferredHeight: Math.round(Style.capsuleHeight * scaling)
    Layout.alignment: Qt.AlignVCenter

    radius: Math.round(Style.radiusM * scaling)
    color: Color.mSurfaceVariant

    // Used to anchor the tooltip, so the tooltip does not move when the content expands
    Item {
      id: anchor
      height: parent.height
      width: 200 * scaling
    }

    Item {
      id: mainContainer
      anchors.fill: parent
      anchors.leftMargin: Style.marginS * scaling
      anchors.rightMargin: Style.marginS * scaling

      Loader {
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        active: Settings.data.audio.showMiniplayerCava && Settings.data.audio.visualizerType == "linear"
                && MediaService.isPlaying
        z: 0

        sourceComponent: LinearSpectrum {
          width: mainContainer.width - Style.marginS * scaling
          height: 20 * scaling
          values: CavaService.values
          fillColor: Color.mOnSurfaceVariant
          opacity: 0.4
        }
      }

      Loader {
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        active: Settings.data.audio.showMiniplayerCava && Settings.data.audio.visualizerType == "mirrored"
                && MediaService.isPlaying
        z: 0

        sourceComponent: MirroredSpectrum {
          width: mainContainer.width - Style.marginS * scaling
          height: mainContainer.height - Style.marginS * scaling
          values: CavaService.values
          fillColor: Color.mOnSurfaceVariant
          opacity: 0.4
        }
      }

      Loader {
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        active: Settings.data.audio.showMiniplayerCava && Settings.data.audio.visualizerType == "wave"
                && MediaService.isPlaying
        z: 0

        sourceComponent: WaveSpectrum {
          width: mainContainer.width - Style.marginS * scaling
          height: mainContainer.height - Style.marginS * scaling
          values: CavaService.values
          fillColor: Color.mOnSurfaceVariant
          opacity: 0.4
        }
      }

      RowLayout {
        id: rowLayout
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.marginS * scaling
        z: 1 // Above the visualizer

        NIcon {
          id: windowIcon
          text: MediaService.isPlaying ? "pause" : "play_arrow"
          font.pointSize: Style.fontSizeL * scaling
          verticalAlignment: Text.AlignVCenter
          Layout.alignment: Qt.AlignVCenter
          visible: !Settings.data.audio.showMiniplayerAlbumArt && getTitle() !== "" && !trackArt.visible
        }

        ColumnLayout {
          Layout.alignment: Qt.AlignVCenter
          visible: Settings.data.audio.showMiniplayerAlbumArt
          spacing: 0

          Item {
            Layout.preferredWidth: Math.round(18 * scaling)
            Layout.preferredHeight: Math.round(18 * scaling)

            NImageCircled {
              id: trackArt
              anchors.fill: parent
              imagePath: MediaService.trackArtUrl
              fallbackIcon: MediaService.isPlaying ? "pause" : "play_arrow"
              borderWidth: 0
              border.color: Color.transparent
            }
          }
        }

        NText {
          id: titleText

          Layout.preferredWidth: {
            if (mouseArea.containsMouse) {
              return Math.round(Math.min(fullTitleMetrics.contentWidth, root.maxWidth * scaling))
            } else {
              return Math.round(Math.min(fullTitleMetrics.contentWidth, root.minWidth * scaling))
            }
          }
          Layout.alignment: Qt.AlignVCenter

          text: getTitle()
          font.pointSize: Style.fontSizeS * scaling
          font.weight: Style.fontWeightMedium
          elide: Text.ElideRight
          verticalAlignment: Text.AlignVCenter
          color: Color.mTertiary

          Behavior on Layout.preferredWidth {
            NumberAnimation {
              duration: Style.animationSlow
              easing.type: Easing.InOutCubic
            }
          }
        }
      }

      // Mouse area for hover detection
      MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: mouse => {
                     if (mouse.button === Qt.LeftButton) {
                       MediaService.playPause()
                     } else if (mouse.button == Qt.RightButton) {
                       MediaService.next()
                       // Need to hide the tooltip instantly
                       tooltip.visible = false
                     } else if (mouse.button == Qt.MiddleButton) {
                       MediaService.previous()
                       // Need to hide the tooltip instantly
                       tooltip.visible = false
                     }
                   }

        onEntered: {
          if (tooltip.text !== "") {
            tooltip.show()
          }
        }
        onExited: {
          tooltip.hide()
        }
      }
    }
  }

  NTooltip {
    id: tooltip
    text: {
      var str = ""
      if (MediaService.canGoNext) {
        str += "Right click for next.\n"
      }
      if (MediaService.canGoPrevious) {
        str += "Middle click for previous."
      }
      return str
    }
    target: anchor
    positionAbove: Settings.data.bar.position === "bottom"
  }
}
