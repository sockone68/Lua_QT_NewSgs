#include "animationpic.h"

AnimationPic::AnimationPic(int LastframeNumber, int wid, int hei, QString dir):current(0)
{
    width=wid;height=hei;
    for(int i=0;i<=LastframeNumber;i++){
        frames.append(QPixmap(QString("%1/%2.png").arg(dir).arg(i)));
    }
}

QRectF AnimationPic::boundingRect() const
{
    return QRectF(0,0,width,height);
}
#include "QPainter"
void AnimationPic::paint(QPainter *painter, const QStyleOptionGraphicsItem *, QWidget *)
{
    painter->drawPixmap(0,0,frames.at(current));
}

void AnimationPic::advance(int phase)
{
    if(phase)current++;
   if(current>=frames.size())
   {
       current = 0;
       //emit this->finished();
       this->deleteLater();
   }
   update();
}

void AnimationPic::timerEvent(QTimerEvent *event)
{
    advance(1);
}
