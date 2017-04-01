#ifndef CLIENTSOCKET_H
#define CLIENTSOCKET_H

#include "QTcpSocket"
class ClientSocket:public QTcpSocket
{
public:
    ClientSocket();
public slots:
    static void dealReceive();
};

#endif // CLIENTSOCKET_H
