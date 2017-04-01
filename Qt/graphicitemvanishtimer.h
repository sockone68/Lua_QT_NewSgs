#ifndef GRAPHICITEMVANISHTIMER_H
#define GRAPHICITEMVANISHTIMER_H

#include "QTimer"
#include "QGraphicsItem"
class GraphicItemVanishTimer : public QTimer
{
    Q_OBJECT
public:
    GraphicItemVanishTimer(QGraphicsItem* item, bool themovedown, int delayms, qreal fromO, qreal OChange, bool isDelete);
private:
    double ticknum;
    bool movedown;
    QGraphicsItem* myitem;
    qreal from,change;
    qreal originO;
    bool deleteItem;
private slots:
    void tick();
};

#endif // GRAPHICITEMVANISHTIMER_H
