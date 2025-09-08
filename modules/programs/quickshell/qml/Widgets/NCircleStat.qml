import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Services
import qs.Widgets

// Compact circular statistic display using Layout management
Rectangle {
  id: root

  property real value: 0 // 0..100 (or any range visually mapped)
  property string icon: ""
  property string suffix: "%"

  // When nested inside a parent group (NBox), you can make it flat
  property bool flat: false
  // Scales the internal content (labels, gauge, icon) without changing the
  // outer width/height footprint of the component
  property real contentScale: 1.0

  width: 68 * scaling
  height: 92 * scaling
  color: flat ? Color.transparent : Color.mSurface
  radius: Style.radiusS * scaling
  border.color: flat ? Color.transparent : Color.mSurfaceVariant
  border.width: flat ? 0 : Math.max(1, Style.borderS * scaling)
  clip: true

  // Repaint gauge when the bound value changes
  onValueChanged: gauge.requestPaint()

  ColumnLayout {
    id: mainLayout
    anchors.fill: parent
    anchors.margins: Style.marginS * scaling * contentScale
    spacing: 0

    // Main gauge container
    Item {
      id: gaugeContainer
      Layout.fillWidth: true
      Layout.fillHeight: true
      Layout.alignment: Qt.AlignCenter
      Layout.preferredWidth: 68 * scaling * contentScale
      Layout.preferredHeight: 68 * scaling * contentScale

      Canvas {
        id: gauge
        anchors.fill: parent
        renderStrategy: Canvas.Cooperative
        onPaint: {
          const ctx = getContext("2d")
          const w = width, h = height
          const cx = w / 2, cy = h / 2
          const r = Math.min(w, h) / 2 - 5 * scaling * contentScale
          // 240° arc with a 120° gap centered on the right side
          // Start at 60° and end at 300° → balanced right-side opening
          const start = Math.PI / 3
          const endBg = Math.PI * 5 / 3
          ctx.reset()
          ctx.lineWidth = 6 * scaling * contentScale
          // Track uses surfaceVariant for stronger contrast
          ctx.strokeStyle = Color.mSurface
          ctx.beginPath()
          ctx.arc(cx, cy, r, start, endBg)
          ctx.stroke()
          // Value arc
          const ratio = Math.max(0, Math.min(1, root.value / 100))
          const end = start + (endBg - start) * ratio
          ctx.strokeStyle = Color.mPrimary
          ctx.beginPath()
          ctx.arc(cx, cy, r, start, end)
          ctx.stroke()
        }
      }

      // Percent centered in the circle
      NText {
        id: valueLabel
        anchors.centerIn: parent
        text: `${root.value}${root.suffix}`
        font.pointSize: Style.fontSizeM * scaling * contentScale
        font.weight: Style.fontWeightBold
        color: Color.mOnSurface
        horizontalAlignment: Text.AlignHCenter
      }

      // Tiny circular badge for the icon, positioned using anchors within the gauge
      Rectangle {
        id: iconBadge
        width: 28 * scaling * contentScale
        height: width
        radius: width / 2
        color: Color.mSurface
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: -6 * scaling * contentScale
        anchors.topMargin: Style.marginXXS * scaling * contentScale

        NIcon {
          anchors.centerIn: parent
          text: root.icon
          font.pointSize: Style.fontSizeLargeXL * scaling * contentScale
          color: Color.mOnSurface
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
        }
      }
    }
  }
}
