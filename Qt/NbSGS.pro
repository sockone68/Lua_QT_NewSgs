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
    ../../Documents/Docs-Resource/lua-5.1.5/src/lapi.c \
    ../../Documents/Docs-Resource/lua-5.1.5/src/lauxlib.c \
    ../../Documents/Docs-Resource/lua-5.1.5/src/lbaselib.c \
    ../../Documents/Docs-Resource/lua-5.1.5/src/lcode.c \
    ../../Documents/Docs-Resource/lua-5.1.5/src/ldblib.c \
    ../../Documents/Docs-Resource/lua-5.1.5/src/ldebug.c \
    ../../Documents/Docs-Resource/lua-5.1.5/src/ldo.c \
    ../../Documents/Docs-Resource/lua-5.1.5/src/ldump.c \
    ../../Documents/Docs-Resource/lua-5.1.5/src/lfunc.c \
    ../../Documents/Docs-Resource/lua-5.1.5/src/lgc.c \
    ../../Documents/Docs-Resource/lua-5.1.5/src/linit.c \
    ../../Documents/Docs-Resource/lua-5.1.5/src/liolib.c \
    ../../Documents/Docs-Resource/lua-5.1.5/src/llex.c \
    ../../Documents/Docs-Resource/lua-5.1.5/src/lmathlib.c \
    ../../Documents/Docs-Resource/lua-5.1.5/src/lmem.c \
    ../../Documents/Docs-Resource/lua-5.1.5/src/loadlib.c \
    ../../Documents/Docs-Resource/lua-5.1.5/src/lobject.c \
    ../../Documents/Docs-Resource/lua-5.1.5/src/lopcodes.c \
    ../../Documents/Docs-Resource/lua-5.1.5/src/loslib.c \
    ../../Documents/Docs-Resource/lua-5.1.5/src/lparser.c \
    ../../Documents/Docs-Resource/lua-5.1.5/src/lstate.c \
    ../../Documents/Docs-Resource/lua-5.1.5/src/lstring.c \
    ../../Documents/Docs-Resource/lua-5.1.5/src/lstrlib.c \
    ../../Documents/Docs-Resource/lua-5.1.5/src/ltable.c \
    ../../Documents/Docs-Resource/lua-5.1.5/src/ltablib.c \
    ../../Documents/Docs-Resource/lua-5.1.5/src/ltm.c \
    ../../Documents/Docs-Resource/lua-5.1.5/src/lundump.c \
    ../../Documents/Docs-Resource/lua-5.1.5/src/lvm.c \
    ../../Documents/Docs-Resource/lua-5.1.5/src/lzio.c \
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


