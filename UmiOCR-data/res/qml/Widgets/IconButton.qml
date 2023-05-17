// =======================================
// =============== 图标按钮 ===============
// =======================================

import QtQuick 2.15

Button_ {
    property string icon_: ""
    property color color: theme.textColor

    contentItem: Icon_ {
        anchors.fill: parent
        anchors.margins: parent.height * 0.2
        
        icon: icon_
        color: parent.color
    }
}