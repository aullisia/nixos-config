import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Services
import qs.Widgets

NPanel {
  id: root

  panelWidth: 400 * scaling
  panelHeight: 500 * scaling
  panelKeyboardFocus: true

  property string passwordSsid: ""
  property string passwordInput: ""
  property string expandedSsid: ""

  onOpened: NetworkService.scan()

  panelContent: Rectangle {
    color: Color.transparent

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: Style.marginL * scaling
      spacing: Style.marginM * scaling

      // Header
      RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginM * scaling

        NIcon {
          text: Settings.data.network.wifiEnabled ? "wifi" : "wifi_off"
          font.pointSize: Style.fontSizeXXL * scaling
          color: Settings.data.network.wifiEnabled ? Color.mPrimary : Color.mOnSurfaceVariant
        }

        NText {
          text: "Wi-Fi"
          font.pointSize: Style.fontSizeL * scaling
          font.weight: Style.fontWeightBold
          color: Color.mOnSurface
          Layout.fillWidth: true
        }

        NToggle {
          id: wifiSwitch
          checked: Settings.data.network.wifiEnabled
          onToggled: checked => NetworkService.setWifiEnabled(checked)
          baseSize: Style.baseWidgetSize * 0.65 * scaling
        }

        NIconButton {
          icon: "refresh"
          tooltipText: "Refresh"
          sizeRatio: 0.8
          enabled: Settings.data.network.wifiEnabled && !NetworkService.scanning
          onClicked: NetworkService.scan()
        }

        NIconButton {
          icon: "close"
          tooltipText: "Close"
          sizeRatio: 0.8
          onClicked: root.close()
        }
      }

      NDivider {
        Layout.fillWidth: true
      }

      // Error message
      Rectangle {
        visible: NetworkService.lastError.length > 0
        Layout.fillWidth: true
        Layout.preferredHeight: errorRow.implicitHeight + (Style.marginM * scaling * 2)
        color: Qt.rgba(Color.mError.r, Color.mError.g, Color.mError.b, 0.1)
        radius: Style.radiusS * scaling
        border.width: Math.max(1, Style.borderS * scaling)
        border.color: Color.mError

        RowLayout {
          id: errorRow
          anchors.fill: parent
          anchors.margins: Style.marginM * scaling
          spacing: Style.marginS * scaling

          NIcon {
            text: "error"
            font.pointSize: Style.fontSizeL * scaling
            color: Color.mError
          }

          NText {
            text: NetworkService.lastError
            color: Color.mError
            font.pointSize: Style.fontSizeS * scaling
            wrapMode: Text.Wrap
            Layout.fillWidth: true
          }

          NIconButton {
            icon: "close"
            sizeRatio: 0.6
            onClicked: NetworkService.lastError = ""
          }
        }
      }

      // Main content area
      Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: Color.transparent

        // WiFi disabled state
        ColumnLayout {
          visible: !Settings.data.network.wifiEnabled
          anchors.fill: parent
          spacing: Style.marginM * scaling

          Item {
            Layout.fillHeight: true
          }

          NIcon {
            text: "wifi_off"
            font.pointSize: 64 * scaling
            color: Color.mOnSurfaceVariant
            Layout.alignment: Qt.AlignHCenter
          }

          NText {
            text: "Wi-Fi is disabled"
            font.pointSize: Style.fontSizeL * scaling
            color: Color.mOnSurfaceVariant
            Layout.alignment: Qt.AlignHCenter
          }

          NText {
            text: "Enable Wi-Fi to see available networks."
            font.pointSize: Style.fontSizeS * scaling
            color: Color.mOnSurfaceVariant
            Layout.alignment: Qt.AlignHCenter
          }

          Item {
            Layout.fillHeight: true
          }
        }

        // Scanning state
        ColumnLayout {
          visible: Settings.data.network.wifiEnabled && NetworkService.scanning && Object.keys(
                     NetworkService.networks).length === 0
          anchors.fill: parent
          spacing: Style.marginL * scaling

          Item {
            Layout.fillHeight: true
          }

          NBusyIndicator {
            running: true
            color: Color.mPrimary
            size: Style.baseWidgetSize * scaling
            Layout.alignment: Qt.AlignHCenter
          }

          NText {
            text: "Scanning for networks..."
            font.pointSize: Style.fontSizeNormal * scaling
            color: Color.mOnSurfaceVariant
            Layout.alignment: Qt.AlignHCenter
          }

          Item {
            Layout.fillHeight: true
          }
        }

        // Networks list container
        ScrollView {
          visible: Settings.data.network.wifiEnabled && (!NetworkService.scanning || Object.keys(
                                                           NetworkService.networks).length > 0)
          anchors.fill: parent
          ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
          ScrollBar.vertical.policy: ScrollBar.AsNeeded
          clip: true

          ColumnLayout {
            width: parent.width
            spacing: Style.marginM * scaling

            // Network list
            Repeater {
              model: {
                if (!Settings.data.network.wifiEnabled)
                  return []

                const nets = Object.values(NetworkService.networks)
                return nets.sort((a, b) => {
                                   if (a.connected !== b.connected)
                                   return b.connected - a.connected
                                   return b.signal - a.signal
                                 })
              }

              Rectangle {
                Layout.fillWidth: true
                implicitHeight: netColumn.implicitHeight + (Style.marginM * scaling * 2)
                radius: Style.radiusM * scaling
                color: modelData.connected ? Qt.rgba(Color.mPrimary.r, Color.mPrimary.g, Color.mPrimary.b,
                                                     0.05) : Color.mSurface
                border.width: Math.max(1, Style.borderS * scaling)
                border.color: modelData.connected ? Color.mPrimary : Color.mOutline

                ColumnLayout {
                  id: netColumn
                  width: parent.width - (Style.marginM * scaling * 2)
                  x: Style.marginM * scaling
                  y: Style.marginM * scaling
                  spacing: Style.marginS * scaling

                  // Main row
                  RowLayout {
                    Layout.fillWidth: true
                    spacing: Style.marginS * scaling

                    NIcon {
                      text: NetworkService.signalIcon(modelData.signal)
                      font.pointSize: Style.fontSizeXXL * scaling
                      color: modelData.connected ? Color.mPrimary : Color.mOnSurface
                    }

                    ColumnLayout {
                      Layout.fillWidth: true
                      spacing: 2 * scaling

                      NText {
                        text: modelData.ssid
                        font.pointSize: Style.fontSizeNormal * scaling
                        font.weight: modelData.connected ? Style.fontWeightBold : Style.fontWeightMedium
                        color: Color.mOnSurface
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                      }

                      RowLayout {
                        spacing: Style.marginXS * scaling

                        NText {
                          text: `${modelData.signal}%`
                          font.pointSize: Style.fontSizeXXS * scaling
                          color: Color.mOnSurfaceVariant
                        }

                        NText {
                          text: "•"
                          font.pointSize: Style.fontSizeXXS * scaling
                          color: Color.mOnSurfaceVariant
                        }

                        NText {
                          text: NetworkService.isSecured(modelData.security) ? modelData.security : "Open"
                          font.pointSize: Style.fontSizeXXS * scaling
                          color: Color.mOnSurfaceVariant
                        }

                        Item {
                          Layout.preferredWidth: Style.marginXXS * scaling
                        }

                        Rectangle {
                          visible: modelData.connected
                          color: Color.mPrimary
                          radius: height * 0.5
                          width: connectedText.implicitWidth + (Style.marginS * scaling * 2)
                          height: connectedText.implicitHeight + (Style.marginXXS * scaling * 2)

                          NText {
                            id: connectedText
                            anchors.centerIn: parent
                            text: "Connected"
                            font.pointSize: Style.fontSizeXXS * scaling
                            color: Color.mOnPrimary
                          }
                        }

                        Rectangle {
                          visible: modelData.cached && !modelData.connected
                          color: Color.transparent
                          border.color: Color.mOutline
                          border.width: Math.max(1, Style.borderS * scaling)
                          radius: height * 0.5
                          width: savedText.implicitWidth + (Style.marginS * scaling * 2)
                          height: savedText.implicitHeight + (Style.marginXXS * scaling * 2)

                          NText {
                            id: savedText
                            anchors.centerIn: parent
                            text: "Saved"
                            font.pointSize: Style.fontSizeXXS * scaling
                            color: Color.mOnSurfaceVariant
                          }
                        }
                      }
                    }

                    // Action area
                    RowLayout {
                      spacing: Style.marginS * scaling

                      NBusyIndicator {
                        visible: NetworkService.connectingTo === modelData.ssid
                        running: visible
                        color: Color.mPrimary
                        size: Style.baseWidgetSize * 0.5 * scaling
                      }

                      NIconButton {
                        visible: (modelData.existing || modelData.cached) && !modelData.connected
                                 && NetworkService.connectingTo !== modelData.ssid
                        icon: "delete"
                        tooltipText: "Forget network"
                        sizeRatio: 0.7
                        onClicked: expandedSsid = expandedSsid === modelData.ssid ? "" : modelData.ssid
                      }

                      NButton {
                        visible: !modelData.connected && NetworkService.connectingTo !== modelData.ssid
                                 && passwordSsid !== modelData.ssid
                        text: {
                          if (modelData.existing || modelData.cached)
                            return "Connect"
                          if (!NetworkService.isSecured(modelData.security))
                            return "Connect"
                          return "Password"
                        }
                        outlined: !hovered
                        fontSize: Style.fontSizeXS * scaling
                        onClicked: {
                          if (modelData.existing || modelData.cached || !NetworkService.isSecured(modelData.security)) {
                            NetworkService.connect(modelData.ssid)
                          } else {
                            passwordSsid = modelData.ssid
                            passwordInput = ""
                            expandedSsid = ""
                          }
                        }
                      }

                      NButton {
                        visible: modelData.connected
                        text: "Disconnect"
                        outlined: !hovered
                        fontSize: Style.fontSizeXS * scaling
                        backgroundColor: Color.mError
                        onClicked: NetworkService.disconnect(modelData.ssid)
                      }
                    }
                  }

                  // Password input
                  Rectangle {
                    visible: passwordSsid === modelData.ssid
                    Layout.fillWidth: true
                    height: passwordRow.implicitHeight + Style.marginS * scaling * 2
                    color: Color.mSurfaceVariant
                    border.color: Color.mOutline
                    border.width: Math.max(1, Style.borderS * scaling)
                    radius: Style.radiusS * scaling

                    RowLayout {
                      id: passwordRow
                      anchors.fill: parent
                      anchors.margins: Style.marginS * scaling
                      spacing: Style.marginM * scaling

                      Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: Style.radiusXS * scaling
                        color: Color.mSurface
                        border.color: pwdInput.activeFocus ? Color.mSecondary : Color.mOutline
                        border.width: Math.max(1, Style.borderS * scaling)

                        TextInput {
                          id: pwdInput
                          anchors.left: parent.left
                          anchors.right: parent.right
                          anchors.verticalCenter: parent.verticalCenter
                          anchors.margins: Style.marginS * scaling
                          text: passwordInput
                          font.pointSize: Style.fontSizeS * scaling
                          color: Color.mOnSurface
                          echoMode: TextInput.Password
                          selectByMouse: true
                          focus: visible
                          passwordCharacter: "●"
                          onTextChanged: passwordInput = text
                          onVisibleChanged: if (visible)
                                              forceActiveFocus()
                          onAccepted: {
                            if (text) {
                              NetworkService.connect(passwordSsid, text)
                              passwordSsid = ""
                              passwordInput = ""
                            }
                          }

                          Text {
                            visible: parent.text.length === 0
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Enter password..."
                            color: Color.mOnSurfaceVariant
                            font.pointSize: Style.fontSizeS * scaling
                          }
                        }
                      }

                      NButton {
                        text: "Connect"
                        fontSize: Style.fontSizeXXS * scaling
                        enabled: passwordInput.length > 0
                        outlined: true
                        onClicked: {
                          NetworkService.connect(passwordSsid, passwordInput)
                          passwordSsid = ""
                          passwordInput = ""
                        }
                      }

                      NIconButton {
                        icon: "close"
                        sizeRatio: 0.8
                        onClicked: {
                          passwordSsid = ""
                          passwordInput = ""
                        }
                      }
                    }
                  }

                  // Forget network
                  Rectangle {
                    visible: expandedSsid === modelData.ssid
                    Layout.fillWidth: true
                    height: forgetRow.implicitHeight + Style.marginS * 2 * scaling
                    color: Color.mSurfaceVariant
                    radius: Style.radiusS * scaling
                    border.width: Math.max(1, Style.borderS * scaling)
                    border.color: Color.mOutline

                    RowLayout {
                      id: forgetRow
                      anchors.fill: parent
                      anchors.margins: Style.marginS * scaling
                      spacing: Style.marginM * scaling

                      RowLayout {
                        NIcon {
                          text: "delete_outline"
                          font.pointSize: Style.fontSizeL * scaling
                          color: Color.mError
                        }

                        NText {
                          text: "Forget this network?"
                          font.pointSize: Style.fontSizeS * scaling
                          color: Color.mError
                          Layout.fillWidth: true
                        }
                      }

                      NButton {
                        id: forgetButton
                        text: "Forget"
                        fontSize: Style.fontSizeXXS * scaling
                        backgroundColor: Color.mError
                        outlined: forgetButton.hovered ? false : true
                        onClicked: {
                          NetworkService.forget(modelData.ssid)
                          expandedSsid = ""
                        }
                      }

                      NIconButton {
                        icon: "close"
                        sizeRatio: 0.8
                        onClicked: expandedSsid = ""
                      }
                    }
                  }
                }
              }
            }
          }
        }

        // Empty state when no networks
        ColumnLayout {
          visible: Settings.data.network.wifiEnabled && !NetworkService.scanning && Object.keys(
                     NetworkService.networks).length === 0
          anchors.fill: parent
          spacing: Style.marginL * scaling

          Item {
            Layout.fillHeight: true
          }

          NIcon {
            text: "wifi_find"
            font.pointSize: 64 * scaling
            color: Color.mOnSurfaceVariant
            Layout.alignment: Qt.AlignHCenter
          }

          NText {
            text: "No networks found"
            font.pointSize: Style.fontSizeL * scaling
            color: Color.mOnSurfaceVariant
            Layout.alignment: Qt.AlignHCenter
          }

          NButton {
            text: "Scan Again"
            icon: "refresh"
            Layout.alignment: Qt.AlignHCenter
            onClicked: NetworkService.scan()
          }

          Item {
            Layout.fillHeight: true
          }
        }
      }
    }
  }
}
