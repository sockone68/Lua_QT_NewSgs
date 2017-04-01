#include "generalpic.h"
#include "qpainter.h"
#include "qcursor.h"
int generalPic::curIndex=1;
int generalPic::theTopestZ=0;
#include "mainwindow.h"
extern MainWindow* mw;
generalPic::generalPic(int w, int h,QPixmap* pic,QRect r):isTextSet(false),text(""),scaleTimer(0),scaleAnimation(0),fromSize(1),opacityTimer(0)
{
    theindex=generalPic::curIndex;//等同于lua中的curPIndex
    generalPic::curIndex++;
    height=h;
    width=w;
    addPic(pic,r);
    this->setCursor(Qt::PointingHandCursor);//需要加qcursor.h
    this->setAcceptHoverEvents(true);
}

generalPic::generalPic(int w, int h, int color, QRect r)
{
    QPixmap* pic=new QPixmap(w,h);
    pic->fill(color);
    new (this)generalPic(w,h,pic,r);
}

generalPic::~generalPic()
{
    if(scaleTimer!=0)
    {
        if(scaleTimer->state()!=QTimeLine::NotRunning)
        {
            scaleTimer->stop();

            scaleTimer->deleteLater();
            scaleTimer=0;
        }


    }
}

void generalPic::addPic(QPixmap *pic, QRect r)
{

    pics.push_back(pic);
    Pos.push_back(r);

}

void generalPic::deletePic(int index)
{
    vector<QPixmap*>::iterator iter=pics.begin()+index;
    pics.erase(iter);
    vector<QRect>::iterator iter2=Pos.begin()+index;
    Pos.erase(iter2);
}
#include "QBitmap"
QImage Bright1(QImage &image,int brightness)
{
    uchar *line =image.scanLine(0);
    uchar *pixel = line;

    for (int y = 0; y < image.height(); ++y)
    {
        pixel = line;
        for (int x = 0; x < image.width(); ++x)
        {
            *pixel = qBound(0, *pixel + brightness, 255);
            *(pixel + 1) = qBound(0, *(pixel + 1) + brightness, 255);
            *(pixel + 2) = qBound(0, *(pixel + 2) + brightness, 255);
            pixel += 4;
        }

        line += image.bytesPerLine();
    }
    return image;
}
void generalPic::setGray()
{/*
    originalPixmap=*pics[0];
    QBitmap bitim=originalPixmap;

    QPixmap* qp=new QPixmap(QPixmap::fromImage(bitim.toImage()));
    pics[0]=qp;update();*/

    originalPixmap=*pics[0];
     QPixmap* qp=pics[0];
    QImage im=qp->toImage();

    int width=im.width();//图像宽
    int height=im.height();//图像高

    int bytePerLine=(width*24+31)/8;//图像每行字节对齐
    unsigned char *data=im.bits();
    unsigned char *graydata=new unsigned char[bytePerLine*height];//存储处理后的数据

    unsigned char r,g,b;
    for (int i=0;i<height;i++)
    {
        for (int j=0;j<width;j++)
        {
            r = *(data+2);
            g = *(data+1);
            b = *data;

            graydata[i*bytePerLine+j*3]  =(r*30+g*59+b*11)/100;
            graydata[i*bytePerLine+j*3+1]=(r*30+g*59+b*11)/100;
            graydata[i*bytePerLine+j*3+2]=(r*30+g*59+b*11)/100;

            data+=4;
        }
    }

    QImage* grayImg=new QImage(graydata,width,height,bytePerLine,QImage::Format_RGB888);
    QPixmap* pim=new QPixmap(QPixmap::fromImage(*grayImg));
    pics[0]=pim;
    update();

}

QRectF generalPic::boundingRect() const
{
    return  QRectF(0,0,width,height);
}
#include "mainwindow.h"
#include "gamethread.h"
extern MainWindow* mw;
#include "QPen"
#include "QRgba64"
void generalPic::paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget *widget)
{
//mw->testWord("paint");
    for(int ix=0;ix!=pics.size();++ix){
        painter->drawPixmap(Pos[ix],*pics[ix]);
    }
    QFont serifFont("Times", 30, QFont::Bold);
    QPen pen(Qt::yellow, 3, Qt::SolidLine, Qt::RoundCap, Qt::RoundJoin);
    if(isSelected())
    {

         painter->setPen(pen);
        painter->drawLine(0,0,0,height);
        painter->drawLine(0,0,width,0);
        painter->drawLine(width,0,width,height);
        painter->drawLine(width,height,width,0);
    }
    if(isTextSet)
    {


         QPen pen(QBrush(QColor::fromRgb(textColor)), 3, Qt::SolidLine, Qt::RoundCap, Qt::RoundJoin);
         painter->setPen(pen);
        painter->setFont(serifFont);
        painter->drawText(textX,textY,textW,textH,Qt::AlignTop|Qt::AlignLeft,text);

    }

    //painter->drawTextItem();
}

void best(QImage* image,QPoint *porigin, QPoint* now,QList<QPoint>* badlist,bool* cantGo,bool* reach){
    int badCount=0;
    QList<QPoint>goodlist;QList<int>goodV;

    for(int x=-1;x<2;x++){
        for(int y=-1;y<2;y++){
            QPoint theP(now->x()+x,now->y()+y);
            if(theP==*porigin)
            {
                *cantGo=true;
                *reach=true;
                return;
            }
            QColor c=image->pixelColor(theP);
            //bool isr=c.redF()>0.8&&c.blueF()<0.2&&c.greenF()<0.2;
            bool isr=(c.red()!=255&&(c.red()==c.blue()||c.red()==c.green()));
            if(isr||(x==0&&y==0)||badlist->contains(theP))
            {
                if(!badlist->contains(theP))
                    badlist->append(theP);
qDebug()<<"?bad"<<c;
                badCount++;
            }
            else
            {

                goodlist<<theP;
                goodV<<abs(theP.x()-porigin->x())+abs(theP.y()-porigin->y());
                if(goodV.count()>1)
                if(goodV.last()>goodV[goodV.count()-2]){
                    int vd=goodV.last();
                    goodV.last()=goodV[goodV.count()-2];
                    goodV[goodV.count()-2]=vd;

                    QPoint pd=goodlist.last();
                    goodlist.last()=goodlist[goodlist.count()-2];
                    goodlist[goodlist.count()-2]=pd;
                }
            }
        }
    }
    if(badCount==9)
    {
        *cantGo=true;
        //return false;
    }
    else
    {

        *now=goodlist.last();
         qDebug()<<"apath"<<*now<<image->pixelColor(*now);
        image->setPixelColor(*now,QColor(0,155,0));
    }
}


bool generalPic::findWay(QPoint porigin, QPoint now)
{
    QPixmap * p=this->pics[0];
    QImage image=p->toImage();
    QList<QPoint> badlist;bool cantGo=false;bool reach=false;

    while(!cantGo)
    {//(QImage* image,QPoint porigin, QPoint* now,QList<QPoint>* badlist,bool* cantGo,bool* reach
        best(&image,&porigin,&now,&badlist,&cantGo,&reach);
    }
    pics[0]=new QPixmap(QPixmap::fromImage(image));
    update();
    if(reach)
        return true;
    else
        return false;
}

#include "QGraphicsSceneMouseEvent"
void generalPic::mousePressEvent(QGraphicsSceneMouseEvent *event)
{
    //this->
    qDebug()<<theindex;
    QPointF p=mapFromScene(event->scenePos());
    /*
    if(findWay(QPoint(244,227),QPoint(p.x(),p.y())))
    {
        mw->testWord("findway");
    }
    else
        mw->testWord("not findway");*/
      mw->gm->call("StdPressedFunc",theindex,p.x(),p.y());


}

#include "mainwindow.h"
#include "QGraphicsSceneMouseEvent"
extern MainWindow* mw;
void generalPic::mouseMoveEvent(QGraphicsSceneMouseEvent *event)
{
    if(mw->gm->loadedTimes>0)
    {
        mw->gm->call("mouseMoveEvent",theindex,event->scenePos().x(),event->scenePos().y());

    }
    QGraphicsItem::mouseMoveEvent(event);
}

void generalPic::hoverMoveEvent(QGraphicsSceneHoverEvent *event)
{
    mw->gm->call("HoverMoveEvent",theindex,event->scenePos().x(),event->scenePos().y());

}

void generalPic::hoverEnterEvent(QGraphicsSceneHoverEvent *event)
{

    mw->gm->call("HoverEnterEvent",theindex,event->scenePos().x(),event->scenePos().y());

}

void generalPic::hoverLeaveEvent(QGraphicsSceneHoverEvent *event)
{
    mw->gm->call("HoverLeaveEvent",theindex,event->scenePos().x(),event->scenePos().y());
}
