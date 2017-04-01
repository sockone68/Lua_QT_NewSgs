#include "growlinetimer.h"

GrowLineTimer::GrowLineTimer(QGraphicsRectItem *g, double l, bool n):ticknum(0)
{
    myr=g;
    if(n)
        len=-l/25;
    else
        len=l/25;
    this->setInterval(10);
    connect(this,SIGNAL(timeout()),this,SLOT(tick()));
    this->start();
}
#include "QDebug"
void GrowLineTimer::tick()
{
    if(ticknum<25)
    {
        QRectF r=myr->rect();

        myr->setRect(r.x(),r.y(),r.width(),r.height()+len);
    }
    else if(ticknum>35)
    {
        delete myr;delete this;
    }
    ticknum++;
    //qDebug()<<ticknum;
}
