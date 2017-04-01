import QtQuick 2.0
ParallelAnimation {
    id:p

    property double theto
    property var thetarget
    running: false
    NumberAnimation {
        property: "width";easing.type: Easing.InOutQuad; duration: 350 ;to:theto;target:p.thetarget
    }

    onStopped: {
        thetarget.destroy()
    }
}
