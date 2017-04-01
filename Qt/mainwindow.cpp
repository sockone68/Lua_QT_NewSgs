#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "QGraphicsRectItem"

#include "qlabel.h"
#include "qpixmap.h"
#include "wujianggamecard.h"
#include "gamethread.h"
#include "thread1.h"
#include <QMetaType>
#include <QTextBlock>

#include "qtimeline.h"
#include "QGraphicsItemAnimation"

#include <QMediaPlayer>
#include <QDir>

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow),isQml(false),qmlLoaded(false)
{
    ui->setupUi(this);

    qRegisterMetaType<QTextBlock>("QTextBlock");
    qRegisterMetaType<QTextCursor>("QTextCursor");
     qRegisterMetaType<QTextCursor>("QTextCharFormat");

    gameView=new gameWidget();
    gameViewLoaded=true;

    mainLayout.addWidget(gameView);

    detailBar=new IOBar();

    mainLayout.addWidget(detailBar);
    ui->centralWidget->setLayout(&mainLayout);

    QSizePolicy qs;
    qs.setHorizontalStretch(1);
    qs.setHorizontalPolicy(QSizePolicy::Expanding);
    qs.setVerticalPolicy(QSizePolicy::Expanding);
    detailBar->setSizePolicy(qs);

    qs1.setHorizontalStretch(4);
    qs1.setHorizontalPolicy(QSizePolicy::Expanding);
    qs1.setVerticalPolicy(QSizePolicy::Preferred);
    gameView->setSizePolicy(qs1);

    QMenu *helpMenu=new QMenu(tr("Game"));
    QAction *startScene=new QAction(tr("Start Scene"),0);
    startScene->setShortcut(QKeySequence(Qt::CTRL|Qt::Key_S));
    QAction *startLua=new QAction(tr("Start Lua"),0);
    startLua->setShortcut(QKeySequence(Qt::CTRL|Qt::Key_L));
    QAction *aboutQtAction=new QAction(tr("About QT"),0);

    QAction *addTexttestAction=new QAction(tr("add word testing"),0);
   // QAction* callTest=new QAction(tr("callTest"),0);
    QAction* clearDetail=new QAction("clear",0);
    QAction* gameEnd=new QAction("End",0);
     gameEnd->setShortcut(QKeySequence(Qt::CTRL|Qt::Key_E));
    QAction* test=new QAction("test",0);
    helpMenu->addAction(startScene);
    helpMenu->addAction(startLua);
    helpMenu->addAction(aboutQtAction);
    helpMenu->addAction(addTexttestAction);
   // helpMenu->addAction(callTest);
    helpMenu->addAction(clearDetail);
    helpMenu->addAction(gameEnd);
    helpMenu->addAction(test);
    ui->menuBar->addMenu(helpMenu);

    connect(aboutQtAction, SIGNAL(triggered()), qApp, SLOT(aboutQt()));
    connect(startScene,SIGNAL(triggered()),this,SLOT(add()));
    connect(addTexttestAction,SIGNAL(triggered(bool)),this,SLOT(testWord()));
    connect(clearDetail,SIGNAL(triggered(bool)),detailBar,SLOT(clear()));
    connect(test,SIGNAL(triggered(bool)),this,SLOT(test()));
    this->resize(1000,600);

     gm=new GameThread();gmLoaded=true;
    connect(startLua,SIGNAL(triggered()),gm,SLOT(start()));
     connect(gameEnd,SIGNAL(triggered(bool)),gm,SLOT(setGameEnd()));

     QAction* e=new QAction("resume",0);helpMenu->addAction(e);
     e->setShortcut(QKeySequence(Qt::Key_Return));
    connect(e,SIGNAL(triggered(bool)),this,SLOT(continueGame()));
//connect(gm,SIGNAL(towake(int)),lw,SLOT(wake(int)));
    //timer=new QTimer();
    //connect(timer,SIGNAL(timeout()),this,SLOT(TimerDo()));
    //timer->start(1000);

}
void MainWindow::clear(){
    //gm->call("clear");
    detailBar->clear();
}

void MainWindow::tM(int pi,int t)
{
    generalPic* gp=gameView->Pics[pi];
    QTimeLine *timer = new QTimeLine(t*1000);
    //timer->setFrameRange(0, 200);

    QGraphicsItemAnimation *animation = new QGraphicsItemAnimation;
    animation->setItem(gp);
    animation->setTimeLine(timer);

    int jingdu=200;
    for (double i = 0; i < jingdu; ++i)
       animation->setScaleAt(i/jingdu,(jingdu-i)/jingdu,1);

    timer->start();
}

void pma(int pi, int x, int y, QTimeLine* timer)
{
    generalPic* gp=mw->gameView->Pics[pi];
    if(gp->scaleTimer!=0)
    {
        gp->scaleTimer->stop();
        delete gp->scaleTimer;
        gp->scaleTimer=0;
    }

    gp->setZValue(generalPic::theTopestZ+1);
    generalPic::theTopestZ++;

    QGraphicsItemAnimation *animation = new QGraphicsItemAnimation;
    animation->setItem(gp);
    animation->setTimeLine(timer);

    double jingdu=24;
    double xii=x/jingdu;
    double yii=y/jingdu;
    for (double i = 0; i < jingdu; ++i){
        double xi=xii*i;
        double yi=yii*i;
        animation->setPosAt(i/jingdu,QPointF(gp->pos().x()+xi,gp->pos().y()+yi));
    }
    timer->start();
}
void MainWindow::picMoveAnimation(int pi, int x, int y, int t)
{

    QTimeLine *timer = new QTimeLine(t);//timer->picIndex=gameView->Pics[pi]->theindex;

   pma(pi,x,y,timer);
}
#include "atimeline1.h"
void MainWindow::PMATD(int fakei,int pi, int x, int y, int t)
{

    ATimeLine1 *timer = new ATimeLine1(t);timer->picIndex=fakei;

    pma(pi,x,y,timer);
}

void MainWindow::pScaleA(int pi,qreal SettingfromSize, qreal changeSize, int t)
{
    QTimeLine *timer = new QTimeLine(t);
    generalPic* gp=gameView->Pics[pi];
    qreal fromSize=gp->fromSize;

    gp->setZValue(generalPic::theTopestZ+1);
    generalPic::theTopestZ++;

    QGraphicsItemAnimation *animation = new QGraphicsItemAnimation;
    animation->setItem(gp);
    animation->setTimeLine(timer);
    double jingdu=48;
    if(gp->scaleTimer!=0)
    {
        if(gp->scaleTimer->state()!=QTimeLine::NotRunning)
        {
             gp->scaleTimer->stop();
        }

        fromSize=gp->scaleAnimation->horizontalScaleAt(gp->scaleTimer->currentValue());
        gp->scaleTimer->deleteLater();
       // gp->scaleTimer=0;
       // gp->scaleAnimation=0;
    }
    gp->scaleTimer=timer;
    gp->scaleAnimation=animation;

    if(fromSize!=SettingfromSize)
        changeSize=SettingfromSize+changeSize-fromSize;

    double sii=changeSize/jingdu;

    for (double i = 0; i < jingdu; ++i){
        double currentChange=sii*i;
        double siii=currentChange+fromSize;
        animation->setScaleAt(i/jingdu,siii,siii);
        if(changeSize>0)
            animation->setPosAt(i/jingdu,QPointF(gp->x()-gp->width*currentChange/2,gp->y()-gp->height*currentChange/2));
        else
            animation->setPosAt(i/jingdu,QPointF(gp->x()-gp->width*(currentChange)/2,gp->y()-gp->height*(currentChange)/2));

    }
    timer->start();
    gp->fromSize=1+changeSize;
}

void MainWindow::playSound(const char *c)
{

    QDir dir;
     QString path=dir.currentPath();
    QMediaPlayer* player = new QMediaPlayer;

    player->setMedia(QUrl::fromLocalFile(path+"/sound/"+c));
     player->setVolume(50);
     player->play();
}
#include "QInputDialog"

void MainWindow::newInputDialog(const char *c1, const char *c2, const char *c3)
{

    bool ok;
    QString text = QInputDialog::getText(this, c1,
                                             c2, QLineEdit::Normal,
                                             c3, &ok);

    if (ok && !text.isEmpty())
    {
         mw->testWord(text);
         lua_pushstring(mw->gm->L,text.toLatin1().data());
         lua_setglobal(mw->gm->L,"stringFromInputDialog");
    }

    mw->gm->call("resume");
}

void MainWindow::deleteGV()
{
    gameView->deleteIB();
    QList<int> l;

   for(int i=0;i<gameView->Pics.count();i++)
   {
       l.append(gameView->Pics[i]->theindex);
   }
   for(int i=0;i<l.count();i++){
        mw->gm->StdCall("stdDeletePic",1,l[i]);
   }
}




MainWindow::~MainWindow()
{
    delete ui;
    if(gameViewLoaded)
        delete gameView;
    if(gmLoaded)
        delete this->gm;
}

void MainWindow::resizeEvent(QResizeEvent *event)
{
    if(!isQml)
    this->gameView->mainView->fitInView(0,0,width,height,Qt::KeepAspectRatio);
    //this->gameView->myView->fitInView(0,0,1000,300,Qt::KeepAspectRatio);
    else
    {
        qw->rootObject()->setSize(QSize(event->size()));
    }

}

void MainWindow::continueGame()
{
    if(mw->gm->isRunning())
        mw->gm->sem.release();
    else
        qDebug()<<"not running";
}

//#include <QMessageBox>
void MainWindow::test()
{

    QString path;
    QDir dir;
    path=dir.currentPath();
   //QMessageBox::warning(0,"PATH",path,QMessageBox::Yes);//查看路径
    QMediaPlayer* player = new QMediaPlayer;
     //connect(player, SIGNAL(positionChanged(qint64)), this, SLOT(positionChanged(qint64)));
     player->setMedia(QUrl::fromLocalFile(path+"/sound/2505.wav"));
     player->setVolume(50);
     player->play();
    //wgc->setScale(0.2);
}

//#include "typeinfo"
#include "generalpic.h"
#include "QGraphicsSimpleTextItem"
#include "QFont"
#include "animationpic.h"
#include "QBitmap"
#include "QGraphicsColorizeEffect"
#include "graphicitemvanishtimer.h"

#include "QTcpSocket"
#include "QTcpServer"
extern QTcpServer*  tcpServer;extern QTcpSocket* tcpSocket;
void MainWindow::tcp1()
{
    testWord("耶");
    QDataStream inn(tcpSocket);
    inn.setVersion(QDataStream::Qt_4_0);
    inn.startTransaction();
    QString s;
    inn>>s;
    if(!inn.commitTransaction()){qDebug()<<"fail";QByteArray b=tcpSocket->readAll();testWord("fail"+QString(b));}
    testWord(s);
}

void MainWindow::tcp2()
{testWord("tcp2");
    QByteArray block;
    QDataStream out(&block, QIODevice::WriteOnly);
    out.setVersion(QDataStream::Qt_4_0);

    out << "fosdfsdfadaf";
    tcpSocket->write(block);
   // tcpSocket->flush();
   // emit t1();
}
QList<QTcpSocket*> clients;
void MainWindow::dealReceive()
{//char* ch;
    qDebug()<<"dealReceive";
    QTcpSocket* ts=(QTcpSocket*)sender();
    QDataStream inn(ts);
    inn.setVersion(QDataStream::Qt_4_0);
    inn.startTransaction();
    QString s;
    std::string sss;
    inn>>s;
    sss=s.toStdString();
    bool flag=false;
    if(!inn.commitTransaction())
    {
        qDebug()<<"fail to receive";
    }
    else
    {
        flag=true;qDebug()<<"receive:"<<s;
    }

    if(sss != ""){
        if(ts!=tcpSocket){

            for(int i=0;i<clients.count();i++){
                if(ts==clients[i]){

                     gm->call("ServerAnswerFunc",i,sss);
                    //emit this->call1("ServerAnswerFunc",i,ch);
                     break;
                }
            }
        }
        else
        {
            gm->call1String("ClientAnswerFunc",sss);

        }
    }

    if(flag)
        dealReceive();
    //if(ts=tcpServer)
}

void MainWindow::disC()
{
    //mw->testWord("disConnected");
    qDebug()<<"disC:"<<sender();
    if(clients.count()>0){
        for(int i=0;i<clients.count();i++){
            if(clients[i]==sender()){
                clients.removeAt(i);
                gm->call("ServerKnowADisconnect",i);
                break;
            }
        }
    }
    else{
        gm->call("ClientKnowSelfDisconnect",0);
    }
}

//listen connections
void MainWindow::server1()
{
    testWord("new c");
    QTcpSocket *client = tcpServer->nextPendingConnection();
    connect(client,&QIODevice::readyRead, this, &MainWindow::dealReceive);
    connect(client,SIGNAL(disconnected()),mw,SLOT(disC()));
    clients<<client;

    gm->call("ServerKnowAConnect");
    /*
    QByteArray block;
    QDataStream out(&block, QIODevice::WriteOnly);
    out.setVersion(QDataStream::Qt_4_0);
    //connect(clientConnection, &QAbstractSocket::disconnected,
        //    clientConnection, &QObject::deleteLater);
    out << "fo";
    client->write(block); //clientConnection->disconnectFromHost();
    */
}

void MainWindow::tcpWriteBlock(QByteArray block)
{
    tcpSocket->write(block);
}



void MainWindow::add()
{


    //int ss[4];
    //this->detailBar->append(typeid(ss).name());
    if(this->gameView==0)
    {
        gameView=new gameWidget();
        mainLayout.addWidget(gameView);
        qDebug()<<"gameView==0 and reload it";
    }
        else
            qDebug()<<"gameView!=0";
    this->detailBar->append("Scene added");

    this->gameView->mainScene->setSceneRect(0,0,width,height);
    QPixmap p("image/gamelogo.png");
    QPixmap pp=p.scaledToWidth(mw->width);
    QBrush br(pp);
    this->gameView->mainScene->setBackgroundBrush(br);
this->gameView->mainView->fitInView(0,0,width,height,Qt::KeepAspectRatio);



}
#include "qfile.h"
extern QTextStream* out;
void MainWindow::testWord(QString s)
{
    detailBar->append(s+";");
    *out <<s << ";" << endl;

    QTextCursor tc=detailBar->textCursor();
    tc.movePosition(QTextCursor::End);
    detailBar->setTextCursor(tc);
    detailBar->isProgramInputed=true;
}
int jl=0;
void MainWindow::testWord(const char *c){
//qDebug()<<"testword threadid:"<<QThread::currentThreadId()<<jl++;
    detailBar->append(QString(c)+";");
    *out << QString(c) << ";" << endl;

    QTextCursor tc=detailBar->textCursor();
    tc.movePosition(QTextCursor::End);
    detailBar->setTextCursor(tc);
    detailBar->isProgramInputed=true;

    //使EditView中文字显示完整
    /*
        detailBar->selectAll();
        tc=detailBar->textCursor();
         tc.movePosition(QTextCursor::End);
         detailBar->setTextCursor(tc);*/
}
#include "QMessageBox"
void MainWindow::e1(QAbstractSocket::SocketError socketError)
{
    switch (socketError) {
    case QAbstractSocket::RemoteHostClosedError:
        break;
    case QAbstractSocket::HostNotFoundError:
        QMessageBox::information(this, tr("Fortune Client"),
                                 tr("The host was not found. Please check the "
                                    "host name and port settings."));
        break;
    case QAbstractSocket::ConnectionRefusedError:
        QMessageBox::information(this, tr("Fortune Client"),
                                 tr("The connection was refused by the peer. "
                                    "Make sure the fortune server is running, "
                                    "and check that the host name and port "
                                    "settings are correct."));
        break;
    default:
        QMessageBox::information(this, tr("Fortune Client"),
                                 tr("The following error occurred: %1.")
                                 .arg(tcpSocket->errorString()));
    }
}

#include "QQmlApplicationEngine"
extern QQmlApplicationEngine* engine;
#include "QQmlContext"
Object1 o;
void MainWindow::AddQML(QString s, QStringList datalist)
{
    qmlRegisterType<Object1>("try1", 1, 0, "Object1");

    engine=new QQmlApplicationEngine();
    QQmlContext *ctxt = engine->rootContext();
    ctxt->setContextProperty("myModel", QVariant::fromValue(datalist));

    ctxt->setContextProperty("o1",&o);
    engine->load(QUrl(QUrl::fromLocalFile("theQmls/"+QString(s))));


}

void MainWindow::useQml()
{
     qw=new QQuickWidget();//qw->setGeometry(width/2,height/2,width,height);
    qmlRegisterType<Object1>("try1", 1, 0, "Object1");

     qw->setSizePolicy(qs1);
     this->takeCentralWidget();

    this->setCentralWidget(qw);
     gameViewLoaded=false;isQml=true;

      qw->setSource(QUrl(QUrl::fromLocalFile("theQmls/main.qml")));
      qw->rootObject()->setSize(size());



      qw->rootContext()->setContextProperty("o1",&o);

}

void MainWindow::tcpWriteBlockToClient(int index, QByteArray block)
{
    clients[index]->write(block);
}


void Object1::qMLCallLua(QString name, QString s)
{
    //qDebug()<<"qmlCalllua threadid:"<<QThread::currentThreadId();
    mw->gm->call1String(name.toLatin1().data(),s.toLatin1().data());
}

void Object1::LuaCallQML(const char *name, const char *s)
{
    //qDebug()<<"LuaCallQML threadid:"<<QThread::currentThreadId();
    QMetaObject::invokeMethod(mw->qw->rootObject(), name,Q_ARG(QVariant, s));

}

void Object1::LuaCallQMLWithStringList(const char *name, QStringList s)
{
    //qDebug()<<"LuaCallQMLWithStringList threadid:"<<QThread::currentThreadId();
    QMetaObject::invokeMethod(mw->qw->rootObject(), name,Q_ARG(QVariant, s));
}

