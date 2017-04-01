#ifndef ATIMELINE1_H
#define ATIMELINE1_H

#include "generaltimeline.h"
class ATimeLine1:public QTimeLine
{
    Q_OBJECT
public:
    int picIndex;
    ATimeLine1(int t);
public slots:
    void deletePic();
};

#endif // ATIMELINE1_H
