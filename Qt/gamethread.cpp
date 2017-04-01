#include "gamethread.h"
#include "QTimerEvent"
#include "QPixmap"
#include "generalpic.h"
//#include <cstdlib>
#include "stdio.h"


GameThread::GameThread()
{

    loadedTimes=0;
    //moveToThread(this);
}

GameThread::~GameThread()
{
    if(LLoaded)
    delete L;
}

int GameThread::clearDeB(lua_State *L){emit mw->gm->clr();return 1;}

int GameThread::tw(lua_State *L)
{
    size_t st;const char* c=lua_tolstring(L,1,&st);
    emit mw->gm->tw1(c);
    return 1;
}

int GameThread::getDetailBarString(lua_State *L)
{ QByteArray ba=mw->detailBar->toPlainText().toLatin1();
    char* ch=ba.data();
    lua_pushstring(L,ch);return 1;
}

int GameThread::addPic(lua_State *L)
{

    int x,y,w,h;

    x=lua_tointeger(L,1);
    y=lua_tointeger(L,2);
    w=lua_tointeger(L,3);
    h=lua_tointeger(L,4);

size_t st;const char* c=lua_tolstring(L,5,&st);

bool isMoveable,isSelectable;
isMoveable=lua_toboolean(L,6);
isSelectable=lua_toboolean(L,7);
const char* tooltip=lua_tolstring(L,8,&st);

    emit mw->gm->ap(c,x,y,w,h,isMoveable,isSelectable,tooltip);

return 1;//return很重要
}

int GameThread::addColorPic(lua_State *L)
{
    int x,y,w,h,color;

    x=lua_tointeger(L,1);
    y=lua_tointeger(L,2);
    w=lua_tointeger(L,3);
    h=lua_tointeger(L,4);

    color=lua_tointeger(L,5);

    bool isMoveable,isSelectable;
    isMoveable=lua_toboolean(L,6);
    isSelectable=lua_toboolean(L,7);size_t st;
    const char* tooltip=lua_tolstring(L,8,&st);

    emit mw->gm->acp(color,x,y,w,h,isMoveable,isSelectable,tooltip);

    return 1;//return很重要
}

int GameThread::addPicForPic(lua_State *L)
{
    int x,y,w,h,index;
    x=lua_tointeger(L,1);
    y=lua_tointeger(L,2);
    w=lua_tointeger(L,3);
    h=lua_tointeger(L,4);
    size_t st;const char* c=lua_tolstring(L,5,&st);
     index=lua_tointeger(L,6);

    emit mw->gm->apfp(c,x,y,w,h,index);
    //lua_pushinteger(L,mw->gameView->curPIPIndex);
     return 1;
}

int GameThread::timeBarM(lua_State *L)
{
    int PIndex,t;
    PIndex=lua_tointeger(L,1);
    t=lua_tointeger(L,2);
    emit mw->gm->tM(PIndex,t);

    return 1;
}

int GameThread::movePic(lua_State *L){
    int i=lua_tointeger(L,1);
    int x,y;
    x=lua_tointeger(L,2);
    y=lua_tointeger(L,3);
   // mw->gameView->Pics[i]->setPos(x,y);
    emit mw->gm->mP(i,x,y);
    return 1;

}

int GameThread::playSound(lua_State *L)
{
     size_t st;const char* c=lua_tolstring(L,1,&st);
    emit mw->gm->pS(c);
     return 1;
}

int GameThread::picMoveAnimation(lua_State *L)
{
    int i=lua_tointeger(L,1);
    int x,y,t;
    x=lua_tointeger(L,2);
    y=lua_tointeger(L,3);
    t=lua_tointeger(L,4);

   // mw->gameView->Pics[i]->setPos(x,y);
    emit mw->gm->pMA(i,x,y,t);
    return 1;
}

int GameThread::picMoveAnimationToDelete(lua_State *L)
{
    int fi=lua_tointeger(L,1);
    int i=lua_tointeger(L,2);
    int x,y,t;
    x=lua_tointeger(L,3);
    y=lua_tointeger(L,4);
    t=lua_tointeger(L,5);
   // mw->gameView->Pics[i]->setPos(x,y);
    emit mw->gm->pMAtoDelete(fi,i,x,y,t);
    return 1;
}

int GameThread::deletePic(lua_State *L)
{
    int x=lua_tointeger(L,1);
     emit mw->gm->dp(x);
    return 1;
}

int GameThread::deletePicForPic(lua_State *L)
{
    int x=lua_tointeger(L,1);
    int y=lua_tointeger(L,2);
     emit mw->gm->dpfp(x,y);
    return 1;
}

int GameThread::addInfoBar(lua_State *L)
{
    size_t st;const char* c=lua_tolstring(L,1,&st);
   emit mw->gm->addIB(c);
    return 1;
}

int GameThread::deleteInfoBar(lua_State *L)
{
    emit mw->gm->dIB();
    return 1;
}

#include "thread1.h"
int GameThread::resumeGameFromPauseByWatingHumanInput(lua_State *L)
{
    //Thread1* t1=new Thread1();
   //t1->start();
     mw->gm->sem.release();
   return 1;
}

int GameThread::getSelection(lua_State *L)
{
    QList<QGraphicsItem *> items=mw->gameView->mainScene->selectedItems();

    lua_newtable(L);
    for(int i=0;i<items.count();i++){
        generalPic* gp=(generalPic*)items[i];
        lua_pushnumber(L,i+1);
        lua_pushnumber(L,gp->theindex);
        lua_settable(L, -3);
    }
    return 1;
}

int GameThread::clearSelection(lua_State *L)
{
    mw->gameView->mainScene->clearSelection();
    return 1;
}

int GameThread::pause(lua_State *L)
{
    mw->gm->sem.acquire();
    return 1;
}

int GameThread::resume(lua_State *L)
{
    mw->gm->sem.release();
    return 1;
}

int GameThread::getpicX(lua_State *L)
{
    int index=lua_tointeger(L,1);
    if(index>mw->gameView->Pics.count())
        lua_pushnumber(L,10000);
    else if(index<0)
        lua_pushnumber(L,90000);
    else
    {
        generalPic* gp=mw->gameView->Pics[index];
        lua_pushnumber(L,gp->pos().x());
    }

    return 1;
}

int GameThread::getpicY(lua_State *L)
{
    int index=lua_tointeger(L,1);
    if(index>mw->gameView->Pics.count())
        lua_pushnumber(L,10000);
    else if(index<0)
        lua_pushnumber(L,90000);
    else
    {
        generalPic* gp=mw->gameView->Pics[index];
        lua_pushnumber(L,gp->pos().y());
    }

    return 1;
}

int GameThread::atfp(lua_State *L)
{
    size_t st;const char* c=lua_tolstring(L,1,&st);

    int x,y,w,h,index,color;
    index=lua_tointeger(L,2);
    x=lua_tointeger(L,3);
    y=lua_tointeger(L,4);
    w=lua_tointeger(L,5);
    h=lua_tointeger(L,6);
    color=lua_tointeger(L,7);
    emit mw->gm->addTextForPic(c,index,x,y,w,h,color);
    //lua_pushinteger(L,mw->gameView->curPIPIndex);
    return 1;
}

int GameThread::changeTextForPic(lua_State *L)
{
    size_t st;const char* c=lua_tolstring(L,1,&st);
    int index;
    index=lua_tointeger(L,2);
    emit mw->gm->changeText(c,index);
    return 1;
}

int GameThread::setColorFade(lua_State *L)
{
    int index=lua_tointeger(L,1);
    mw->gameView->Pics[index]->setOpacity(0.5);
    return 1;
}

int GameThread::restoreFade(lua_State *L)
{
    int index=lua_tointeger(L,1);
    mw->gameView->Pics[index]->setOpacity(1);
    return 1;
}

int GameThread::avl(lua_State *L)
{
    double x1,y1,x2,y2;
    x1=lua_tonumber(L,1);
    y1=lua_tonumber(L,2);
    x2=lua_tonumber(L,3);
    y2=lua_tonumber(L,4);
    emit mw->gm->avl(x1,y1,x2,y2);
}

int GameThread::addTextPic(lua_State *L)
{
    size_t st;const char* c=lua_tolstring(L,1,&st);
    int x,y,w,h;
    x=lua_tointeger(L,2);
    y=lua_tointeger(L,3);
    w=lua_tointeger(L,4);
    h=lua_tointeger(L,5);
    emit mw->gm->atp(c,x,y,w,h);
}

int GameThread::count(lua_State *L)
{
    lua_pushnumber(L,mw->gameView->Pics.count());
    return 1;
}

int GameThread::setWp(lua_State *L)
{
    size_t st;const char* c=lua_tolstring(L,1,&st);
    mw->gameView->setWallpaper(c);
    return 1;
}

int GameThread::quitG(lua_State *L)
{

    emit mw->gm->dGV();


    return 1;
}

int GameThread::AAM(lua_State *L)
{
    int x,y,w,h,Lindex;
    x=lua_tointeger(L,1);
    y=lua_tointeger(L,2);
    Lindex=lua_tointeger(L,3);
    w=lua_tointeger(L,4);
    h=lua_tointeger(L,5);
    size_t st;const char* c=lua_tolstring(L,6,&st);


    emit mw->gm->addAnim(x,y,Lindex,w,h,c);
    //lua_pushinteger(L,mw->gameView->curPIPIndex);
    return 1;
}

int GameThread::sleep(lua_State *L)
{
    int  x=lua_tointeger(L,1);
    QThread::msleep(x);
    return 1;
}
#include <QDesktopServices>

extern QDir dir;

int GameThread::openFileInApp(lua_State *L)
{
    size_t st;const char* c=lua_tolstring(L,1,&st);
    QDesktopServices::openUrl(QUrl("file://"+dir.currentPath()+"/"+c, QUrl::TolerantMode));
    return 1;
}

int GameThread::inputDialog(lua_State *L)
{
    size_t st;const char* chead=lua_tolstring(L,1,&st);
    const char* cinfo=lua_tolstring(L,2,&st);
    const char* cdefalut=lua_tolstring(L,3,&st);
    emit mw->gm->newIDialog(chead,cinfo,cdefalut);
    return 1;
}

int GameThread::PicScaleAnimation(lua_State *L)
{
    int  i=lua_tointeger(L,1);
    qreal  fsize=lua_tonumber(L,2);
    qreal  tsize=lua_tonumber(L,3);
    int  time=lua_tointeger(L,4);
    emit mw->gm->pscale(i,fsize,tsize,time);
    return 1;
}

int GameThread::setGray(lua_State *L)
{
    int index=lua_tointeger(L,1);
    //mw->gameView->Pics[index]->setGray();
    emit mw->gm->setgray(index);
    return 1;
}
#include "QGraphicsColorizeEffect"
int GameThread::setColorize(lua_State *L)
{
    int index=lua_tointeger(L,1);
    int color=lua_tointeger(L,2);

    QGraphicsColorizeEffect* ce=new QGraphicsColorizeEffect();
    ce->setColor(color);

    mw->gameView->Pics[index]->setGraphicsEffect(ce);

    return 1;
}

int GameThread::restoreColorize(lua_State *L)
{
    int index=lua_tointeger(L,1);
    mw->gameView->Pics[index]->setGraphicsEffect(0);

    return 1;
}
#include "graphicitemvanishtimer.h"
int GameThread::vanishPic(lua_State *L)
{
    int index=lua_tointeger(L,1);
    qreal from=lua_tonumber(L,2);
    qreal change=lua_tonumber(L,3);

   new GraphicItemVanishTimer(mw->gameView->Pics[index],false,0,from,change,false);
    return 1;
}

int GameThread::addQml(lua_State *L)
{
    size_t st;const char* s=lua_tolstring(L,1,&st);
    int sum=lua_tointeger(L,2);
    //qDebug()<<sum;


    QStringList dataList;
    lua_getglobal(L, "theTable1");
    for(int i=1;i<=sum;i++){
        lua_pushinteger(L, i);
        lua_gettable(L, -2);
        if (!lua_isstring(L, -1))
           luaL_error(L,"invalid string ");
        const char* result = (const char*)lua_tostring(L, -1);
        lua_pop(L, 1);
        dataList.append(result);
    }

    emit mw->gm->aqml(s,dataList);
    return 1;
}
/*
#include "QQmlApplicationEngine"
extern QQmlApplicationEngine* engine;
#include "QQmlContext"

int GameThread::addContentForQml(lua_State *L)
{
    if(engine!=0){
        int sum=lua_tointeger(L,1);
        QQmlContext *ctxt = engine->rootContext();
        QStringList dataList;
        lua_getglobal(L, "theTable1");
        for(int i=1;i<=sum;i++){
            lua_pushinteger(L, i);
            lua_gettable(L, -2);
            if (!lua_isstring(L, -1))
               luaL_error(L,"invalid string ");
            const char* result = (const char*)lua_tostring(L, -1);
            lua_pop(L, 1);
            dataList.append(result);
        }
        ctxt->setContextProperty("myModel", QVariant::fromValue(dataList));
    }

}
*/
#include "QTcpSocket"
#include "QTcpServer"
QTcpServer*  tcpServer=0;
QTcpSocket* tcpSocket=0;
int GameThread::startServer(lua_State *L)
{
    if(tcpServer==0)
    {
        tcpServer= new QTcpServer();
        connect(tcpServer, &QTcpServer::newConnection, mw, &MainWindow::server1);

       if (!tcpServer->listen(QHostAddress::Any,54321)) {qDebug()<<"fuckf";}
       else
           qDebug()<<"hahaYes server started!";
    }
    return 1;
}

int GameThread::startClient(lua_State *L)
{
    if(tcpSocket==0)
    {
       tcpSocket=new QTcpSocket();
       //connect(tcpSocket,&QAbstractSocket::connected, mw, &MainWindow::tcp2);
       connect(tcpSocket,&QIODevice::readyRead, mw, &MainWindow::dealReceive);
       connect(tcpSocket,SIGNAL(disconnected()),mw,SLOT(disC()));
        tcpSocket->connectToHost("localhost",54321);
        //mw->tcp2();
    }

    return 1;
}

int GameThread::sendMsgToServer(lua_State *L)
{
    if(tcpSocket!=0)
    {
        QByteArray block;
        QDataStream out(&block, QIODevice::WriteOnly);
        out.setVersion(QDataStream::Qt_4_0);
        size_t st;const char* s=lua_tolstring(L,1,&st);
        qDebug()<<"send msg toServer:"<<s;
        out << QString(s);
        //tcpSocket->write(block);
        emit mw->gm->w1(block);
    }
    return 1;
}
extern QList<QTcpSocket*> clients;
int GameThread::sendMsgToClient(lua_State *L)
{
    if(tcpServer!=0)
    {
        int i=lua_tointeger(L,1);
        if(i<clients.count()){
            //mw->testWord(QString("send msg to clent_%1").arg(i));
           // emit mw->gm->tw1(QString("send msg to clent_%1").arg(i).toLatin1().data());
            qDebug()<<"clientn"<<i;
            QByteArray block;
            QDataStream out(&block, QIODevice::WriteOnly);
            out.setVersion(QDataStream::Qt_4_0);
            size_t st;const char* s=lua_tolstring(L,2,&st);
            //emit mw->gm->tw1(QString("thesend msg is:%1").arg(s).toLatin1().data());
            qDebug()<<"send msg toclient:"<<s;
            out << QString(s);
            emit mw->gm->w2(i,block);
            //clients[i]->write(block);
        }


    }
    return 1;
}

int GameThread::findWay(lua_State *L)
{
    int index,x,y,xn,yn;
    index=lua_tointeger(L,1);
    x=lua_tointeger(L,2);
    y=lua_tointeger(L,3);
    xn=lua_tointeger(L,4);
    yn=lua_tointeger(L,5);

    QPoint porigin(x,y);
    QPoint now(xn,yn);

    mw->gameView->Pics[index]->findWay(porigin,now);
    return 1;
}
extern Object1 o;

int GameThread::emitCallQmlFunction(lua_State *L)
{
    //size_t st;
    const char* c=lua_tostring(L,1);
    const char* c2=lua_tostring(L,2);
    //o.LuaCallQML(c,c2);
    emit mw->gm->s1(c,c2);
    return 1;
}

int GameThread::useQML(lua_State *L)
{
    mw->useQml();

    return 1;
}

int GameThread::emitCallQmlFWithTable(lua_State *L)
{
    size_t st;
    const char* s=lua_tolstring(L,1,&st);
    int sum=lua_tointeger(L,2);
    //qDebug()<<sum;


    QStringList dataList;
    lua_getglobal(L, "theTable1");
    for(int i=1;i<=sum;i++){
        lua_pushinteger(L, i);
        lua_gettable(L, -2);
        if (!lua_isstring(L, -1))
           luaL_error(L,"invalid string ");
        const char* result = (const char*)lua_tostring(L, -1);
        lua_pop(L, 1);
        dataList.append(result);
    }

    //emit mw->gm->s2(s,dataList);
    o.LuaCallQMLWithStringList(s,dataList);
    return 1;
}
#include "thread1.h"
int GameThread::newT(lua_State *L)
{
    Thread1* t=new Thread1();
    t->start();
    return 1;
}

int GameThread::qtLog(lua_State *L)
{
     size_t st;const char* s=lua_tolstring(L,1,&st);
     qDebug()<<"luaQtLog"<<s;
}



void GameThread::run()
{//qDebug()<<"luarun threadid:"<<QThread::currentThreadId();
    connect(mw,SIGNAL(call1(char*,int,char*)),this,SLOT(call(char*,int,char*)));

    connect(this,SIGNAL(clr()),mw,SLOT(clear()));
    connect(this,SIGNAL(ap(QString,int,int,int,int,bool,bool,QString)),mw->gameView,SLOT(addPic(QString,int,int,int,int,bool,bool,QString)));
    connect(this,SIGNAL(apfp(QString,int,int,int,int,int)),mw->gameView,SLOT(addPicForPic(QString,int,int,int,int,int)));
    connect(this,SIGNAL(tM(int,int)),mw,SLOT(tM(int,int)));
    connect(this,SIGNAL(mP(int,int,int)),mw,SLOT(mP(int,int,int)));
    connect(this,SIGNAL(pS(const char*)),mw,SLOT(playSound(const char*)));
    connect(this,SIGNAL(pMA(int,int,int,int)),mw,SLOT(picMoveAnimation(int,int,int,int)));
     connect(this,SIGNAL(pMAtoDelete(int,int,int,int,int)),mw,SLOT(PMATD(int,int,int,int,int)));
    connect(this,SIGNAL(dp(int)),mw->gameView,SLOT(deletePic(int)));
    connect(this,SIGNAL(dpfp(int,int)),mw->gameView,SLOT(deletePicForPic(int,int)));
    connect(this,SIGNAL(tw1(const char*)),mw,SLOT(testWord(const char*)));
    connect(this,SIGNAL(addIB(const char*)),mw->gameView,SLOT(addIB(const char*)));
    connect(this,SIGNAL(dIB()),mw->gameView,SLOT(deleteIB()));
    connect(this,SIGNAL(addTextForPic(const char*,int,int,int,int,int,int)),mw->gameView,SLOT(addTextForPic(const char*,int,int,int,int,int,int)));
    connect(this,SIGNAL(changeText(const char*,int)),mw->gameView,SLOT(changeText(const char*,int)));
    connect(this,SIGNAL(avl(double,double,double,double)),mw->gameView,SLOT(addVLine(double,double,double,double)));
    connect(this,SIGNAL(atp(const char*,int,int,int,int)),mw->gameView,SLOT(addTextPic(const char*,int,int,int,int)));
    connect(this,SIGNAL(dGV()),mw,SLOT(deleteGV()));
    connect(this,SIGNAL(addAnim(double,double,int,int,int,QString)),mw->gameView,SLOT(addAnimation(double,double,int,int,int,QString)));
    connect(this,SIGNAL(newIDialog(const char*,const char*,const char*)),mw,SLOT(newInputDialog(const char*,const char*,const char*)));
    connect(this,SIGNAL(pscale(int,qreal,qreal,int)),mw,SLOT(pScaleA(int,qreal,qreal,int)));
    connect(this,SIGNAL(acp(int,int,int,int,int,bool,bool,QString)),mw->gameView,SLOT(addColorPic(int,int,int,int,int,bool,bool,QString)));
    loadG();
    connect(this,SIGNAL(setgray(int)),mw->gameView,SLOT(setGray(int)));
    connect(this,SIGNAL(aqml(QString,QStringList)),mw,SLOT(AddQML(QString,QStringList)));
    connect(this,SIGNAL(s1(const char*,const char*)),&o,SLOT(LuaCallQML(const char*,const char*)));
    //connect(this,SIGNAL(s2(const char*,QStringList)),&o,SLOT(LuaCallQMLWithStringList(const char*,QStringList)));
    connect(this,SIGNAL(w1(QByteArray)),mw,SLOT(tcpWriteBlock(QByteArray)));
    connect(this,SIGNAL(w2(int,QByteArray)),mw,SLOT(tcpWriteBlockToClient(int,QByteArray)));

    call();
}

void GameThread::load(char *filename)
{
    loadedTimes++;
    if(loadedTimes>1)delete L;
    L = luaL_newstate();LLoaded=true;
    luaL_openlibs(L);
    //lua_register(L,"wakeUp",wake);
    lua_register(L,"printForGame",tw);
    lua_register(L,"at",aT);
    lua_register(L,"getBarString",getDetailBarString);
   lua_register(L,"addPic",addPic);
    lua_register(L,"deletePic",deletePic);
   lua_register(L,"apfp",addPicForPic);
   lua_register(L,"dpfp",deletePicForPic);
 lua_register(L,"tM",timeBarM);
    lua_register(L,"mP",movePic);
    lua_register(L,"clearD",clearDeB);
     lua_register(L,"playSound",playSound);
     lua_register(L,"PMA",picMoveAnimation);
       lua_register(L,"PMATD",picMoveAnimationToDelete);
       lua_register(L,"addInfoBar",addInfoBar);
       lua_register(L,"deleteInfoBar",deleteInfoBar);
        lua_register(L,"RGFPBWHI",resumeGameFromPauseByWatingHumanInput);
    lua_register(L,"getPicSelection",getSelection);
    lua_register(L,"clearPicSelection",clearSelection);
    lua_register(L,"pause",pause);
lua_register(L,"resume",resume);
    lua_register(L,"getPicX",getpicX);
    lua_register(L,"getPicY",getpicY);
    lua_register(L,"atfp",atfp);
     lua_register(L,"ctfp",changeTextForPic);
    lua_register(L,"setFade",setColorFade);
    lua_register(L,"restoreFade",restoreFade);
    lua_register(L,"avl",avl);
    lua_register(L,"atp",addTextPic);
    lua_register(L,"picCount",count);
    lua_register(L,"setWp",setWp);
    lua_register(L,"quit",quitG);
    lua_register(L,"AAM",AAM);
    lua_register(L,"sleep",sleep);
    lua_register(L,"openFileInApp",openFileInApp);

    lua_register(L,"inputDialog",inputDialog);
    lua_register(L,"PicScaleAnimation",PicScaleAnimation);

    //17.1.3
    lua_register(L,"setGray",setGray);
    lua_register(L,"addColorPic",addColorPic);
    lua_register(L,"setColorize",setColorize);
    lua_register(L,"restoreColorize",restoreColorize);
    lua_register(L,"vanishPic",vanishPic);
    //1.5
    lua_register(L,"addQml",addQml);
    //1.6
    lua_register(L,"startServer",startServer);
    lua_register(L,"startClient",startClient);
    lua_register(L,"sendMsgToServer",sendMsgToServer);
    lua_register(L,"sendMsgToClient",sendMsgToClient);

    //1.7
    lua_register(L,"findWay",findWay);
    lua_register(L,"emitCallQmlFunction",emitCallQmlFunction);

    //1.8
    lua_register(L,"useqml",useQML);
    lua_register(L,"emitCallQmlFWithTable",emitCallQmlFWithTable);
    //1.22
    lua_register(L,"newT",newT);
    //1.24
    lua_register(L,"qtLog",qtLog);
   if (luaL_loadfile(L, filename) || lua_pcall(L, 0, 0, 0))
      luaL_error(L, "cannot run configuration file: %s", lua_tostring(L, -1));

}
#include "QCoreApplication"
void GameThread::loadG()
{

    load("game.lua");
}

void GameThread::call(char *fname){
    lua_getglobal(L, fname);
    if (lua_pcall(L, 0, 0, 0) != 0){qDebug()<<lua_tostring(L, -1);mw->testWord(lua_tostring(L, -1));}
    //luaL_error(L, "call error : %s",lua_tostring(L, -1));
}

void GameThread::call(char *fname, int index)
{
    lua_getglobal(L, fname);
    lua_pushinteger(L,index);
    if (lua_pcall(L, 1, 0, 0) != 0){qDebug()<<lua_tostring(L, -1);mw->testWord(lua_tostring(L, -1));}
}

void GameThread::call(char *fname, int index, char *s)
{

    lua_getglobal(L, fname);
    lua_pushinteger(L,index);
    lua_pushstring(L,s);
    if (lua_pcall(L, 2, 0, 0) != 0){qDebug()<<lua_tostring(L, -1);mw->testWord(lua_tostring(L, -1));}

}

void GameThread::call(char *fname, int index, std::string s)
{
    lua_getglobal(L, fname);
    lua_pushinteger(L,index);
    lua_pushlstring(L,s.c_str(),s.size());
    if (lua_pcall(L, 2, 0, 0) != 0){qDebug()<<lua_tostring(L, -1);mw->testWord(lua_tostring(L, -1));}

}

void GameThread::call(char *fname, qreal x, qreal y)
{
    lua_getglobal(L, fname);
    lua_pushnumber(L,x);
    lua_pushnumber(L,y);
    if (lua_pcall(L, 2, 0, 0) != 0)qDebug()<<lua_tostring(L, -1);
}

void GameThread::call(char *fname, int index, qreal x, qreal y)
{
    lua_getglobal(L, fname);
    lua_pushinteger(L,index);
    lua_pushnumber(L,x);
    lua_pushnumber(L,y);
    if (lua_pcall(L, 3, 0, 0) != 0)qDebug()<<lua_tostring(L, -1);
}

void GameThread::call1String(char *fname, char *s){
    lua_getglobal(L, fname);
    lua_pushstring(L,s);
    if (lua_pcall(L, 1, 0, 0) != 0)qDebug()<<lua_tostring(L, -1);
}

void GameThread::call1String(char *fname, std::__1::string s)
{
    lua_getglobal(L, fname);
    lua_pushlstring(L,s.c_str(),s.size());
    if (lua_pcall(L, 1, 0, 0) != 0){qDebug()<<lua_tostring(L, -1);mw->testWord(lua_tostring(L, -1));}
}

const char *GameThread::callStdReturnString(int actIndex, int param){
    lua_getglobal(L, "StdReturnString");
    lua_pushinteger(L,actIndex);
    lua_pushinteger(L,param);
    if (lua_pcall(L, 2, 1, 0) != 0)qDebug()<<lua_tostring(L, -1);
    size_t st;const char* c=lua_tolstring(L,1,&st);
    lua_pop(L, 1);
    return c;
}

void GameThread::StdCall(char* fname,int actIndex, int param){
    lua_getglobal(L, fname);
    lua_pushinteger(L,actIndex);
    lua_pushinteger(L,param);
    if (lua_pcall(L, 2, 0, 0) != 0)qDebug()<<lua_tostring(L, -1);
}


