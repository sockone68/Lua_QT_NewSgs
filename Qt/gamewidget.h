#ifndef GAMEWIDGET_H
#define GAMEWIDGET_H

#include <QWidget>
#include <QVBoxLayout>
#include <QGraphicsScene>
#include <qgraphicsview.h>
#include "generalpic.h"
#include "gamescene.h"
class gameWidget : public QWidget
{
    Q_OBJECT
public:
    explicit gameWidget(QWidget *parent = 0);
     void paintEvent(QPaintEvent *);
     ~gameWidget();

     QSize minimumSizeHint() const ;
     GameScene *mainScene;
      QGraphicsView *mainView;

      QList<generalPic*> Pics;
      QList<QGraphicsSimpleTextItem*> InfoBars;

signals:

public slots:
      void dealSelection();

 void addPic(QString n, int x, int y, int w, int h, bool isMoveable, bool isSelectable, QString tip);
 void addColorPic(int color, int x, int y, int w, int h, bool isMoveable, bool isSelectable, QString tip);

 void addTextForPic(const char *n, int index, int x, int y, int w, int h, int color);
    void changeText(const char *n, int index);
  void deletePic(int index);
  void deletePicForPic(int pindex,int ppindex);
 void addPicForPic(QString n, int x, int y, int w, int h, int index);
 void addIB(const char* s);
 void deleteIB();
void addVLine(double x1, double y1, double x2, double y2);
void addTextPic(const char *n, int x, int y, int w, int h);

void setWallpaper(const char *n);
void addAnimation(double x, double y, int LastframeNumber, int wid, int hei, QString dir);
void setGray(int index);
private:
     QVBoxLayout* mainLayout;


};

#endif // GAMEWIDGET_H
