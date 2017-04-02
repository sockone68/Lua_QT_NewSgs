#-------------------------------------------------
#
# Project created by QtCreator 2016-08-24T14:47:43
#
#-------------------------------------------------

QT       += qml quick \
            core gui\
            quickwidgets
QT += multimedia
greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = NbSGS
TEMPLATE = app


SOURCES += main.cpp\
        mainwindow.cpp \
    gamewidget.cpp \
    generalpic.cpp \
    iobar.cpp \
    gamethread.cpp \
    atimeline1.cpp \
    graphicitemvanishtimer.cpp \
    growlinetimer.cpp \
    animationpic.cpp \
    gamescene.cpp \
    ../lua-5.1.5/src/lapi.c \
    ../lua-5.1.5/src/lauxlib.c \
    ../lua-5.1.5/src/lbaselib.c \
    ../lua-5.1.5/src/lcode.c \
    ../lua-5.1.5/src/ldblib.c \
    ../lua-5.1.5/src/ldebug.c \
    ../lua-5.1.5/src/ldo.c \
    ../lua-5.1.5/src/ldump.c \
    ../lua-5.1.5/src/lfunc.c \
    ../lua-5.1.5/src/lgc.c \
    ../lua-5.1.5/src/linit.c \
    ../lua-5.1.5/src/liolib.c \
     ../lua-5.1.5/src/llex.c \
      ../lua-5.1.5/src/lmathlib.c \
      ../lua-5.1.5/src/lmem.c \
    ../lua-5.1.5/src/loadlib.c \
    ../lua-5.1.5/src/lobject.c \
    ../lua-5.1.5/src/lopcodes.c \
    ../lua-5.1.5/src/loslib.c \
    ../lua-5.1.5/src/lparser.c \
    ../lua-5.1.5/src/lstate.c \
    ../lua-5.1.5/src/lstring.c \
    ../lua-5.1.5/src/lstrlib.c \
    ../lua-5.1.5/src/ltable.c \
    ../lua-5.1.5/src/ltablib.c \
    ../lua-5.1.5/src/ltm.c \
    ../lua-5.1.5/src/lundump.c \
    ../lua-5.1.5/src/lvm.c \
    ../lua-5.1.5/src/lzio.c \
    thread1.cpp

HEADERS  += mainwindow.h \
    gamewidget.h \
    generalpic.h \
    iobar.h \
    gamethread.h \
    atimeline1.h \
    graphicitemvanishtimer.h \
    growlinetimer.h \
    animationpic.h \
    gamescene.h \
    thread1.h

FORMS    += mainwindow.ui


