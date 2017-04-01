#ifndef WUJIANGGAMECARD_H
#define WUJIANGGAMECARD_H
#include "qgraphicsitem.h"

class WujiangGameCard:public QGraphicsItem
{

public:
    WujiangGameCard();
    enum{width=200,height=289};
    QPixmap* WJpic;
    QPixmap* Wqpic;
    QPixmap* Fjpic;
    QPixmap* Jiaypic;
    QPixmap* Jianypic;
    // QGraphicsItem interface
public:
    QRectF boundingRect() const;
    void paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget *widget);
};

#endif // WUJIANGGAMECARD_H
