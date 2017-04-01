#ifndef THREAD1_H
#define THREAD1_H
#include "qthread.h"

class Thread1:public QThread
{
    Q_OBJECT
public:
    Thread1();

public slots:

    void run();

};

#endif // THREAD1_H
