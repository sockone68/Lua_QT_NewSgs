#ifndef ANIMATIONPIC_H
#define ANIMATIONPIC_H
#include "qgraphicsitem.h"


class AnimationPic:public QGraphicsItem,public QObject
{
public:
    AnimationPic(int LastframeNumber, int wid, int hei, QString dir);
    QList<QPixmap> frames;

    // QGraphicsItem interface

    QRectF boundingRect() const;
    void paint(QPainter *painter, const QStyleOptionGraphicsItem *, QWidget *);

private:
    int current;
    int width,height;
    // QGraphicsItem interface
public:
    void advance(int phase);

    // QObject interface
protected:
    void timerEvent(QTimerEvent *event);
};

#endif // ANIMATIONPIC_H
