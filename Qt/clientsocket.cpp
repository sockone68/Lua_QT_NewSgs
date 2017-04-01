#include "clientsocket.h"

ClientSocket::ClientSocket()
{
    connect(this,&QIODevice::readyRead,this,&ClientSocket::dealReceive);
}

#include "mainwindow.h"
extern MainWindow* mw;

