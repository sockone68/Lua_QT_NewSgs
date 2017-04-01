#include "wujianggamecard.h"
#include "qpainter.h"
WujiangGameCard::WujiangGameCard()
{
    setFlags(ItemIsSelectable|ItemIsMovable);
    WJpic=new QPixmap("mario.png");
   *WJpic=WJpic->scaled(QSize(width,height),Qt::KeepAspectRatio);
     Wqpic=new QPixmap("axe.png");
}

QRectF WujiangGameCard::boundingRect() const
{
    return QRectF(0,0,width,height);
}

void WujiangGameCard::paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget *widget)
{


    painter->drawPixmap(0,0,width,height,*WJpic);
    painter->drawPixmap(0,height-Wqpic->height(),width,Wqpic->height(),*Wqpic);
}
