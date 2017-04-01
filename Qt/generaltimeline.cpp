#include "generaltimeline.h"
#include "mainwindow.h"
extern MainWindow* mw;
#include "gamethread.h"
GeneralTimeLine::GeneralTimeLine(int t)
{
    connect(this,SIGNAL(stateChanged(QTimeLine::State)),this,SLOT(DoWhenStop(QTimeLine::State)));
     //connect(this,SIGNAL(finished()),this,SLOT(DoWhenF()));
     this->setDuration(t);
}

void GeneralTimeLine::DoWhenStop(QTimeLine::State s)
{
    if(s==QTimeLine::Paused||s==QTimeLine::NotRunning)
    {
        qDebug()<<"stoped";
        lua_State* L=mw->gm->L;
       lua_getglobal(L, "getTrueIndex");   /* function to be called */
       lua_pushinteger(L, picIndex);    /* push 1st argument */

       int z;
       /* do the call (1 arguments, 1 result) */
       if (lua_pcall(L, 1, 1, 0) != 0)
         luaL_error(L, "error running function `getTrueIndex': %s",
              lua_tostring(L, -1));

       /* retrieve result */
       if (!lua_isnumber(L, -1))
          luaL_error(L, "function `getTrueIndex' must return a number");
       z = lua_tonumber(L, -1);
       lua_pop(L, 1);
       generalPic* gp=mw->gameView->Pics[z];
       qDebug()<<"yes";
       if(gp->scaleTimer!=0)
       {
           gp->scaleTimer->stop();
           qDebug()<<"2";
           //gp->scaleTimer->deleteLater();
           gp->scaleTimer=0;
            qDebug()<<"haha";
       }
    }

}

void GeneralTimeLine::DoWhenF()
{
    qDebug()<<"F";
    lua_State* L=mw->gm->L;
   lua_getglobal(L, "getTrueIndex");   /* function to be called */
   lua_pushinteger(L, picIndex);    /* push 1st argument */

   int z;
   /* do the call (1 arguments, 1 result) */
   if (lua_pcall(L, 1, 1, 0) != 0)
     luaL_error(L, "error running function `getTrueIndex': %s",
          lua_tostring(L, -1));

   /* retrieve result */
   if (!lua_isnumber(L, -1))
      luaL_error(L, "function `getTrueIndex' must return a number");
   z = lua_tonumber(L, -1);
   lua_pop(L, 1);
   generalPic* gp=mw->gameView->Pics[z];
    qDebug()<<"yesF";
   if(gp->scaleTimer!=0)
   {
       gp->scaleTimer->stop();
       gp->scaleTimer->deleteLater();
       gp->scaleTimer=0;
       qDebug()<<"hahaF";
   }
}
