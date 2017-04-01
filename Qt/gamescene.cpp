#include "gamescene.h"
#include "mainwindow.h"
extern MainWindow* mw;
#include "gamethread.h"
GameScene::GameScene()
{

}
#include "QGraphicsSceneMouseEvent"
void GameScene::mousePressEvent(QGraphicsSceneMouseEvent *event)
{
    if(mw->gm->loadedTimes>0)
    {
        mw->gm->call("mousePressEvent",event->scenePos().x(),event->scenePos().y());
        QGraphicsScene::mousePressEvent(event);
    }

}
