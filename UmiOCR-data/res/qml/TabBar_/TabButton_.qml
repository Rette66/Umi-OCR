// ==================================================
// =============== 水平标签栏的标签按钮 ===============
// ==================================================

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15 // 阴影

import "../Widgets"

Button {
    id: btn

    // 设定值
    property string title: "Unknown TabBtn" // 显示的标题
    property int index: -1 // 在标签栏中的序号

    // 默认值
    checkable: false // 手动控制
    z: checked? 10 : 0 // 选中模式下弹到顶层
    // 信号
    signal dragStart(int index) // 开始拖拽的信号
    signal dragFinish(int index) // 结束拖拽的信号
    signal dragMoving(int index, int x) // 拖拽移动的信号

    // 按钮前景
    contentItem: RowLayout {
        // anchors.fill: parent

        // TODO: 图标
        Item {
            width: theme.textSize*0.2 // 先占位
        }

        // 标题
        Text_ {
            text: title // 外部传入的title
            
            elide: Text.ElideRight // 隐藏超出宽度
            Layout.fillWidth: true // 填充宽度
            height: btn.height // 适应整个按钮的高度
            color: (parent.parent.hovered || parent.parent.checked)?theme.textColor:theme.subTextColor
            font.bold: btn.checked
        }

        // 关闭按钮
        IconButton {
            // 未锁定，且主按钮悬停或选中时才显示
            visible: !app.tab.barIsLock && (parent.parent.hovered || parent.parent.checked)
            Layout.alignment: Qt.AlignRight
            Layout.rightMargin: theme.hTabBarHeight * 0.2

            property real size: theme.hTabBarHeight * 0.7
            implicitWidth: size
            implicitHeight: size
            bgColor_: "#00000000"

            icon_: "close"

            onClicked: {
                app.tab.delTabPage(index)
            }
        }
    }

    // 按钮背景
    background: Rectangle {
        anchors.fill: parent
        
        color: parent.checked ? theme.tabColor : (
            parent.hovered ? theme.coverColor1 : theme.coverColor0
        )

        // 侧边小条
        Rectangle{
            visible: !parent.parent.checked
            height: parent.height-20
            width: 1
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            color: theme.subTextColor
        }

        // 边缘阴影
        layer.enabled: theme.enabledEffect && parent.checked
        layer.effect: DropShadow {
            transparentBorder: true
            color: theme.coverColor3
            samples: theme.hTabBarShadowHeight
        }

        // 点击和拖拽处理
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton

            // 拖拽
            drag.target: app.tab.barIsLock ? null : parent.parent // 动态启用、禁用拖拽
            drag.axis: Drag.XAxis // 只能沿X轴
            drag.threshold: 50 // 起始阈值
            property bool dragActive: drag.active // 动态记录拖拽状态
            property int dragX: parent.parent.x // 动态记录拖拽时整体的位置
            
            onPressed: { // 左键按下，切换焦点
                if(mouse.button === Qt.LeftButton) {
                    app.tab.showTabPage(index)
                }
            }
            onClicked: { // 中键点击，删除标签
                if(mouse.button === Qt.MiddleButton && !app.tab.barIsLock) {
                    app.tab.delTabPage(index)
                }
            }
            onDragActiveChanged: {
                if(drag.active) { // 拖拽开始
                    parent.opacity = 0.6
                    parent.parent.y += parent.parent.height / 2
                    dragStart(index)
                } else { // 拖拽结束
                    parent.opacity = 1
                    parent.parent.y -= parent.parent.height / 2
                    dragFinish(index)
                }
            }
            onDragXChanged: {
                if(drag.active) {
                    dragMoving(index, dragX)
                }
            }
        }
    }


    // 选中时的放大动画
    property bool enabledAni: false // true是允许动画
    property bool runAni: false
    Timer { // 计时器，保证初始化的一段时间内不允许动画
        running: true
        interval: 300
        onTriggered: enabledAni=true
    }
    onCheckedChanged: {
        if(enabledAni) runAni = checked
    }
    SequentialAnimation{ // 串行动画
        running: theme.enabledEffect && runAni
        // 动画1：放大
        NumberAnimation{
            target: btn
            property: "scale"
            to: 1.2
            duration: 80
            easing.type: Easing.OutCubic
        }
        // 动画2：缩小
        NumberAnimation{
            target: btn
            property: "scale"
            to: 1
            duration: 150
            easing.type: Easing.InCubic
        }
    }
}