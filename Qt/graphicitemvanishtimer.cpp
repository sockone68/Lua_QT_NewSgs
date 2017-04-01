#include "graphicitemvanishtimer.h"
#include "QTimer"
#include "generalpic.h"
#include "qdebug.h"
GraphicItemVanishTimer::GraphicItemVanishTimer(QGraphicsItem *item, bool themovedown, int delayms,qreal fromO,qreal OChange,bool isDelete):ticknum(0),deleteItem(isDelete)
{
    myitem=item;movedown=themovedown;from=fromO;change=OChange;
    originO=item->opacity();
    if(originO!=fromO)
    {
        change=fromO+OChange-originO;
    }
    this->setInterval(40);
    connect(this,SIGNAL(timeout()),this,SLOT(tick()));
    generalPic * gp=0;
    if((gp=dynamic_cast<generalPic*>(item))!=0)
    {
        if(gp->opacityTimer!=0){
            if(gp->opacityTimer->isActive())
            {
                 gp->opacityTimer->stop();qDebug()<<"stop";
                  gp->opacityTimer->deleteLater();
            }


        }

        gp->opacityTimer=this;
    }

     QTimer::singleShot(delayms, this, SLOT(start()));

}

void GraphicItemVanishTimer::tick()
{
    myitem->setOpacity(originO+ticknum/25*change);

    if(movedown)
        myitem->moveBy(0,1);
    ticknum++;
    if(ticknum>=25){

        generalPic * gp=0;
        if((gp=dynamic_cast<generalPic*>(myitem))!=0)
        {
            gp->opacityTimer=0;
        }
        if(deleteItem)
        delete myitem;

        delete this;
    }
}
