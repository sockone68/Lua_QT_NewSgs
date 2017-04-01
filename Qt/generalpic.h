#ifndef GENERALPIC_H
#define GENERALPIC_H
#include "qgraphicsitem.h"
#include <vector>
using std::vector;
#include "QTimeLine"
#include "generaltimeline.h"
#include "QGraphicsItemAnimation"
#include "graphicitemvanishtimer.h"

class generalPic:public QGraphicsItem
{

public:

    generalPic(int w, int h, QPixmap *pic, QRect r);
     generalPic(int w, int h, int color,QRect r);
    ~generalPic();
    vector<QPixmap*> pics;
    vector<QRect> Pos;
    int width;
    int height;


    bool isTextSet;
    int textX,textY,textW,textH;
    const char* text;
    int textColor;

static int curIndex;
    int theindex;//not the real index,it always increases
static int theTopestZ;

    void addPic(QPixmap* pic, QRect r);
    void deletePic(int index);

    QPixmap originalPixmap;
    void setGray();
    // QGraphicsItem interface
    qreal fromSize;
    QTimeLine* scaleTimer;
     QGraphicsItemAnimation *scaleAnimation;
     QTimer* opacityTimer;
public:
    QRectF boundingRect() const;
    void paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget *widget);

    bool findWay(QPoint porigin, QPoint now);
    // QGraphicsItem interface
protected:
    void mousePressEvent(QGraphicsSceneMouseEvent *event);

    void mouseMoveEvent(QGraphicsSceneMouseEvent *event);

    void hoverMoveEvent(QGraphicsSceneHoverEvent *event);

    void hoverEnterEvent(QGraphicsSceneHoverEvent *event);
    void hoverLeaveEvent(QGraphicsSceneHoverEvent *event);
};

#endif // GENERALPIC_H
