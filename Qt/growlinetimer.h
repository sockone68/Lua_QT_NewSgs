#ifndef GROWLINETIMER_H
#define GROWLINETIMER_H
#include "QTimer"
#include "QGraphicsRectItem"

class GrowLineTimer : public QTimer
{
    Q_OBJECT
public:
    GrowLineTimer(QGraphicsRectItem* g,double l,bool n);
private:
    int ticknum;
    double len;
    QGraphicsRectItem* myr;
private slots:
    void tick();

};

#endif // GROWLINETIMER_H
