#ifndef GAMESCENE_H
#define GAMESCENE_H
#include "QGraphicsScene"

class GameScene:public QGraphicsScene
{
    Q_OBJECT
public:
    GameScene();

    // QGraphicsScene interface
protected:
    void mousePressEvent(QGraphicsSceneMouseEvent *event);
};

#endif // GAMESCENE_H
