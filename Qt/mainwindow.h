#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>

#include <qtextedit.h>
#include <QHBoxLayout>
#include <gamewidget.h>
#include <QShortcut>
#include "iobar.h"
#include "string"
#include "QTimer"
#include "QDebug"
#include "QAbstractSocket"
#include <QQuickWidget>
#include "QQuickItem"

namespace Ui {

class MainWindow;
}
class GameModel;
class GameThread;
class Object1:public QObject
{
    Q_OBJECT
public:

    Object1(){}
    Object1(const Object1&){}

public slots:

    void qMLCallLua(QString name,QString s);
    void LuaCallQML(const char* name,const char*  s);
    void LuaCallQMLWithStringList(const char* name,QStringList s);
signals:
    void jj(QString ss);
};

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();

    enum{width=1400,height=960};//int curIndex;
    GameThread* gm;bool gmLoaded;
    QHBoxLayout mainLayout;
    gameWidget* gameView;bool gameViewLoaded;bool qmlLoaded;QQuickWidget * qw;
    bool isQml;QSizePolicy qs1;
     IOBar* detailBar;
     //QShortcut* detailBarEnter;
    void resizeEvent(QResizeEvent *event);

typedef void (QAbstractSocket::*QAbstractSocketErrorSignal)(QAbstractSocket::SocketError);
private:
    Ui::MainWindow *ui;

public slots:
    void continueGame();
    void test();
    void add();
      void testWord(QString s);
      void testWord(const char* c);
     void testWord(){testWord("test");}
    void clear();
    void tM(int pi, int t);
    void picMoveAnimation(int pi,int x,int y,int t);
    void PMATD(int fakei, int pi, int x, int y, int t);//动画完毕后删除图片
    void pScaleA(int pi, qreal SettingfromSize, qreal changeSize, int t);
    void mP(int i,int x,int y){gameView->Pics[i]->setPos(x,y);}
    void playSound(const char* c);
    void newInputDialog(const char* c1,const char* c2,const char* c3);
    void deleteGV();
    void AddQML(QString s,QStringList datalist);

    void tcp1();void tcp2();void server1();void tcpWriteBlock(QByteArray block);void e1(QAbstractSocket::SocketError socketError);
    void dealReceive();void disC();
    void useQml();
    void tcpWriteBlockToClient(int index,QByteArray block);

signals:
    void call1(char*,int,char*);
};

#endif // MAINWINDOW_H
