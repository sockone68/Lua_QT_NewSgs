#include "gamewidget.h"
#include "qpainter.h"
#include "qdebug.h"
#include "mainwindow.h"
extern MainWindow* mw;
gameWidget::gameWidget(QWidget *parent) : QWidget(parent)
{
    mainLayout=new QVBoxLayout();
    mainScene = new GameScene();




    mainView = new QGraphicsView;
    mainView->setScene(mainScene);
    mainView->setDragMode(QGraphicsView::RubberBandDrag);
    mainView->setRenderHints(QPainter::Antialiasing
                         | QPainter::TextAntialiasing);
    mainView->setContextMenuPolicy(Qt::ActionsContextMenu);
    mainLayout->addWidget(mainView);
   this->setLayout(mainLayout);

 connect(this->mainScene,SIGNAL(selectionChanged()),this,SLOT(dealSelection()));
/*


        QSizePolicy qs1;
        qs1.setVerticalStretch(3);
        //qs1.setHorizontalStretch(4);
        qs1.setHorizontalPolicy(QSizePolicy::Expanding);
        qs1.setVerticalPolicy(QSizePolicy::Expanding);
        mainView->setSizePolicy(qs1);*/
}

void gameWidget::paintEvent(QPaintEvent *ew)
{
    /*
    QPainter painter(this);

    painter.setRenderHint(QPainter::Antialiasing,true);
    painter.setPen(QPen(Qt::black,1,Qt::SolidLine,Qt::RoundCap));
    painter.drawLine(0,0,0,360);
    painter.drawLine(0,0,40,66);
    */
}

gameWidget::~gameWidget()
{
    /*
    for(int i=0;i<Pics.count();i++){
        deletePic(Pics.count()-1);
    }*/
    delete mainView;
    delete mainScene;

}

QSize gameWidget::minimumSizeHint() const
{
    return QSize(360,240);
}
#include "gamethread.h"
void gameWidget::dealSelection()
{
    QList<QGraphicsItem *> items=mainScene->selectedItems();
    lua_State* L=mw->gm->L;
    lua_newtable(L);
    for(int i=0;i<items.count();i++){
        generalPic* gp=(generalPic*)items[i];
        lua_pushnumber(L,i+1);
        lua_pushnumber(L,gp->theindex);
        lua_settable(L, -3);
    }

    lua_getglobal(L,"GetSelectionTable");
    lua_pushvalue(L,-2);
    if (lua_pcall(L, 1, 0, 0) != 0)qDebug()<<lua_tostring(L, -1);
}

void gameWidget::addPic(QString n, int x, int y, int w, int h, bool isMoveable, bool isSelectable,QString tip)
{
    generalPic* gp=new generalPic(w,h,new QPixmap(n),QRect(0,0,w,h));
    if(isMoveable)
        gp->setFlags(gp->flags()|QAbstractGraphicsShapeItem::ItemIsMovable);
    if(isSelectable)
        gp->setFlags(QAbstractGraphicsShapeItem::ItemIsSelectable|gp->flags());

    this->mainScene->addItem(gp);
    gp->setPos(x,y);
    gp->setZValue(generalPic::theTopestZ+1);
    generalPic::theTopestZ++;
    if(tip!="")
        gp->setToolTip(tip);
    //gp->mapToScene(x,y);
    Pics.append(gp);
    //this->repaint();
}

void gameWidget::addColorPic(int color, int x, int y, int w, int h, bool isMoveable, bool isSelectable, QString tip)
{
    generalPic* gp=new generalPic(w,h,color,QRect(0,0,w,h));
    if(isMoveable)
        gp->setFlags(gp->flags()|QAbstractGraphicsShapeItem::ItemIsMovable);
    if(isSelectable)
        gp->setFlags(QAbstractGraphicsShapeItem::ItemIsSelectable|gp->flags());

    this->mainScene->addItem(gp);
    gp->setPos(x,y);
    gp->setZValue(generalPic::theTopestZ+1);
    generalPic::theTopestZ++;
    if(tip!="")
        gp->setToolTip(tip);
    //gp->mapToScene(x,y);
    Pics.append(gp);
}

void gameWidget::addTextForPic(const char *n, int index, int x, int y, int w, int h,int color)
{
    generalPic* gp=Pics[index];
    gp->text=n;
    gp->textX=x;
    gp->textY=y;
    gp->textH=h;
    gp->textW=w;
    gp->textColor=color;
    gp->isTextSet=true;
    gp->update();
}

void gameWidget::changeText(const char *n, int index)
{
     Pics[index]->text=n;
     Pics[index]->update();
}
#include "QStyleOptionGraphicsItem"
void gameWidget::addPicForPic(QString n, int x, int y, int w, int h, int index)
{
    this->Pics[index]->addPic(new QPixmap(n),QRect(x,y,w,h));
   //this->curPIPIndex= Pics[index]->pics.size();

    Pics[index]->update();

}
#include "mainwindow.h"
extern MainWindow* mw;
#include "QGraphicsSimpleTextItem"
#include "graphicitemvanishtimer.h"
void gameWidget::addIB(const char *s)
{
    QGraphicsSimpleTextItem* gst=new QGraphicsSimpleTextItem(s);
    QFont serifFont("Times", 50, QFont::Bold);
    gst->setFont(serifFont);
    mainScene->addItem(gst);

    InfoBars.insert(0,gst);
    gst->setPos((mw->width-gst->boundingRect().width())/2,300);

    for(int i=0;i<InfoBars.count();i++){
         QGraphicsSimpleTextItem* gs=InfoBars[i];
         gs->setY(300+50*i);
         if(i!=0)
         {
             new GraphicItemVanishTimer(gs,true,1000,1,-1,false);
         }
    }
    for(int i=1;i<InfoBars.count();i++){
         InfoBars.removeLast();
    }
    gst->setZValue(generalPic::theTopestZ+1);
    generalPic::theTopestZ++;



}

void gameWidget::deleteIB()
{
    for(int i=0;i<InfoBars.count();i++){
         QGraphicsSimpleTextItem* gs=InfoBars[i];
         new GraphicItemVanishTimer(gs,true,1000,1,-1,false);
    }
    InfoBars.clear();
}
#include "QGraphicsRectItem"
#include "math.h"
#include "QTimeLine"
#include "QGraphicsItemAnimation"
#include "growlinetimer.h"
void gameWidget::addVLine(double x1, double y1, double x2, double y2)
{
    QGraphicsRectItem* ri=new QGraphicsRectItem(x1,y1,-4,-1);
    ri->setBrush(Qt::yellow);
    ri->setPen(QPen(Qt::transparent,0));
    ri->setZValue(generalPic::theTopestZ+1);
    generalPic::theTopestZ++;

    mainScene->addItem(ri);


    ri->setTransformOriginPoint(x1,y1);
    double dx,dy;
    dx=x1-x2;
    dy=y1-y2;
    double d;
    bool n=true;
    if(dy==0)
        if(dx>0)
            d=-90;
        else
            d=90;
    else
    {d=(-atan(dx/dy))*180/3.14;n=dy>0;}
    ri->setRotation(d);
    new GrowLineTimer(ri,sqrt(dx*dx+dy*dy),n);

}

void gameWidget::addTextPic(const char *n, int x, int y, int w, int h)
{
    QPixmap* pm=new QPixmap(w,h);
    pm->fill(Qt::transparent);
    generalPic* gp=new generalPic(w,h,pm,QRect(0,0,w,h));
    this->mainScene->addItem(gp);
    gp->setPos(x,y);
    Pics.append(gp);
    gp->text=n;
    gp->textX=0;
    gp->textY=0;
    gp->textH=h;
    gp->textW=w;
    gp->textColor=Qt::black;
    gp->isTextSet=true;
    gp->update();
}

void gameWidget::setWallpaper(const char *n)
{
    mainScene->setSceneRect(0,0,mw->width,mw->height);
    QPixmap p(n);
    QPixmap pp=p.scaledToWidth(mw->width);
    QBrush b(pp);
    mainScene->setBackgroundBrush(b);
    mainScene->update();
}
#include "animationpic.h"
void gameWidget::addAnimation(double x,double y,int LastframeNumber, int wid, int hei, QString dir)
{
    AnimationPic* ap=new AnimationPic(LastframeNumber,wid,hei,dir);
    ap->setPos(x,y);
    ap->setZValue(generalPic::theTopestZ+1);
    generalPic::theTopestZ++;
    mainScene->addItem(ap);
    ap->startTimer(50);
}

void gameWidget::setGray(int index)
{
    Pics[index]->setGray();
}



void gameWidget::deletePic(int index)
{
    if(index<Pics.count()&&index>-1)
    {
        generalPic* gp=Pics[index];
        Pics.removeAt(index);
        if (gp->scene()==mainScene )
            this->mainScene->removeItem(gp);
        else
            qDebug()<<"different scene";

        delete gp;
    }

}

void gameWidget::deletePicForPic(int pindex, int ppindex)
{
    Pics[pindex]->deletePic(ppindex);

    Pics[pindex]->update();
}
