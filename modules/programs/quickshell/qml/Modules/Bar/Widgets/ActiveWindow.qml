import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
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
  visible: getTitle() !== ""

  function getTitle() {
    return CompositorService.focusedWindowTitle !== "(No active window)" ? CompositorService.focusedWindowTitle : ""
  }

  function getAppIcon() {
    // Try CompositorService first
    const focusedWindow = CompositorService.getFocusedWindow()
    if (focusedWindow && focusedWindow.appId) {
      return Icons.iconForAppId(focusedWindow.appId.toLowerCase())
    }

    // Fallback to ToplevelManager
    if (ToplevelManager && ToplevelManager.activeToplevel) {
      const activeToplevel = ToplevelManager.activeToplevel
      if (activeToplevel.appId) {
        return Icons.iconForAppId(activeToplevel.appId.toLowerCase())
      }
    }

    return ""
  }

  // A hidden text element to safely measure the full title width
  NText {
    id: fullTitleMetrics
    visible: false
    text: getTitle()
    font.pointSize: Style.fontSizeS * scaling
    font.weight: Style.fontWeightMedium
  }

  Rectangle {
    id: windowTitleRect
    visible: root.visible
    Layout.preferredWidth: contentLayout.implicitWidth + Style.marginM * 2 * scaling
    Layout.preferredHeight: Math.round(Style.capsuleHeight * scaling)
    radius: Math.round(Style.radiusM * scaling)
    color: Color.mSurfaceVariant

    Item {
      id: mainContainer
      anchors.fill: parent
      anchors.leftMargin: Style.marginS * scaling
      anchors.rightMargin: Style.marginS * scaling
      clip: true

      RowLayout {
        id: contentLayout
        anchors.centerIn: parent
        spacing: Style.marginS * scaling

        // Window icon
        Item {
          Layout.preferredWidth: Style.fontSizeL * scaling * 1.2
          Layout.preferredHeight: Style.fontSizeL * scaling * 1.2
          Layout.alignment: Qt.AlignVCenter
          visible: getTitle() !== "" && Settings.data.bar.showActiveWindowIcon

          IconImage {
            id: windowIcon
            anchors.fill: parent
            source: getAppIcon()
            asynchronous: true
            smooth: true
            visible: source !== ""
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
          horizontalAlignment: Text.AlignLeft
          text: getTitle()
          font.pointSize: Style.fontSizeS * scaling
          font.weight: Style.fontWeightMedium
          elide: mouseArea.containsMouse ? Text.ElideNone : Text.ElideRight
          verticalAlignment: Text.AlignVCenter
          color: Color.mSecondary
          clip: true

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
      }
    }
  }

  Connections {
    target: CompositorService
    function onActiveWindowChanged() {
      windowIcon.source = Qt.binding(getAppIcon)
    }
    function onWindowListChanged() {
      windowIcon.source = Qt.binding(getAppIcon)
    }
  }
}
