#ifndef GAMETHREAD_H
#define GAMETHREAD_H
extern "C" {
#include <../lua-5.1.5/src/lua.h>
#include <../lua-5.1.5/src/lauxlib.h>
#include <../lua-5.1.5/src/lualib.h>
#include <../lua-5.1.5/src/luaconf.h>
}
#include "qthread.h"
#include "qdebug.h"
#include "mainwindow.h"

extern MainWindow* mw;
#include "qdir.h"
#include "QSemaphore"
class GameThread:public QThread
{
    Q_OBJECT
public:


    GameThread();
    ~GameThread();
    lua_State *L;bool LLoaded;
    int loadedTimes;
    static int clearDeB(lua_State *L);
    static  int tw(lua_State *L);
   static int aT(lua_State* L){mw->add();return 1;}
   static int getDetailBarString(lua_State* L);
   static int addPic(lua_State* L);
   static int addColorPic(lua_State*L);
   static int addPicForPic(lua_State* L);
    static int timeBarM(lua_State* L);
    static int movePic(lua_State* L);
    static int playSound(lua_State* L);
    static int picMoveAnimation(lua_State* L);
     static int picMoveAnimationToDelete(lua_State* L);
    static int deletePic(lua_State* L);
    static int deletePicForPic(lua_State* L);
    static int addInfoBar(lua_State* L);
    static int deleteInfoBar(lua_State* L);
    static int resumeGameFromPauseByWatingHumanInput(lua_State* L);
    static int getSelection(lua_State* L);
    static int clearSelection(lua_State*L);
QSemaphore sem;//不知道为什么，貌似把sem放在类初始化函数声明的上方会有问题，把sem变成指针也会有问题,指针的明白前一个不明白
     static int pause(lua_State* L);
      static int resume(lua_State* L);
      //17.1.30
       //
    static int getpicX(lua_State* L);
     static int getpicY(lua_State* L);
     static int  atfp(lua_State *L);
     static int changeTextForPic(lua_State* L);
     static int setColorFade(lua_State*L);
     static int restoreFade(lua_State*L);
    static int avl(lua_State* L);
    static int addTextPic(lua_State* L);
    static int count(lua_State*L);
    static int setWp(lua_State*L);
    static int quitG(lua_State*L);
    static int AAM(lua_State*L);
    static int sleep(lua_State*L);
    static int openFileInApp(lua_State*L);
    static int inputDialog(lua_State*L);
    static int PicScaleAnimation(lua_State*L);

    static int setGray(lua_State*L);
    static int setColorize(lua_State*L);
    static int restoreColorize(lua_State*L);

     static int vanishPic(lua_State*L);
     static int addQml(lua_State*L);
    //static int addContentForQml(lua_State*L);


     static int startServer(lua_State*L);
     static int startClient(lua_State*L);
     static int sendMsgToServer(lua_State*L);
     static int sendMsgToClient(lua_State*L);

     //1.7
     static int findWay(lua_State*L);
     static int emitCallQmlFunction(lua_State*L);
     //1.8
     static int useQML(lua_State*L);
      static int emitCallQmlFWithTable(lua_State*L);
    //1.22
      static int newT(lua_State*L);
    //1.24
      static int qtLog(lua_State*L);

signals:

     void s1(const char*,const char*);
     //void s2(const char*,QStringList);
      //1.16
      void w1(QByteArray);
      void w2(int,QByteArray);
void dGV();
void aqml(QString,QStringList);
    void newIDialog(const char*,const char*,const char*);
   void tw1(const char *c);
    void clr();
   void ap(QString,int,int,int,int,bool,bool,QString);
   void dp(int);
   void dpfp(int,int);
   void apfp(QString,int,int,int,int,int);
 void tM(int,int);
    void mP(int,int,int);
    void pS(const char*);
    void pMA(int,int,int,int);
    void pMAtoDelete(int,int,int,int,int);
    void addIB(const char*);
    void dIB();
    void addTextForPic(const char *, int , int , int , int , int ,int);
    void changeText(const char *, int );
    void avl(double,double,double,double);
    void atp(const char *, int , int , int , int );
    void addAnim(double ,double ,int , int , int , QString );
    void pscale(int ,qreal,qreal,int);

    void setgray(int);


    void acp(int,int,int,int,int,bool,bool,QString);
     //
public slots:
   void setGameEnd(){const char* ch="End";lua_pushstring(L,ch);lua_setglobal(L,"gameState");mw->testWord("<h3>Game Ended</h3> ");}

void run();
    void load (char *filename);
   void loadG();

   inline void call(){call("gameMain");}
   void call(char* fname);
   void call(char *fname,int index);
   void call(char *fname,int index,char* s);

   void call(char *fname,int index,std::string s);

   void call(char *fname,qreal x,qreal y);
   void call(char *fname,int index,qreal x,qreal y);

   void call1String(char* fname,char* s);
    void call1String(char* fname,std::string s);

   const char* callStdReturnString(int actIndex,int param);
   void StdCall(char *fname, int actIndex, int param);
};

#endif // GAMETHREAD_H
