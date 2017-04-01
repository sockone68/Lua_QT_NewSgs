#include "atimeline1.h"
#include "mainwindow.h"
#include "generalpic.h"
extern MainWindow* mw;
#include "gamethread.h"
ATimeLine1::ATimeLine1(int t)//:GeneralTimeLine(t)
{
    this->setDuration(t);
    connect(this,SIGNAL(finished()),this,SLOT(deletePic()));

}

void ATimeLine1::deletePic()
{
   // DoWhenF();
    //mw->gameView->deletePic(picIndex);
    /*
     lua_State* L=mw->gm->L;
    lua_getglobal(L, "getTrueIndex");   /* function to be called
    lua_pushinteger(L, picIndex);    /* push 1st argument

    int z;
    /* do the call (1 arguments, 1 result)
    if (lua_pcall(L, 1, 1, 0) != 0)
      luaL_error(L, "error running function `getTrueIndex': %s",
           lua_tostring(L, -1));

    /* retrieve result
    if (!lua_isnumber(L, -1))
       luaL_error(L, "function `getTrueIndex' must return a number");
    z = lua_tonumber(L, -1);
    lua_pop(L, 1);
    generalPic* gp=mw->gameView->Pics[z];
    if(gp->scaleTimer!=0)
    {
        gp->scaleTimer->stop();
        delete gp->scaleTimer;
        gp->scaleTimer=0;
    }
*/
    mw->gm->StdCall("stdDeletePic",1,picIndex);
    delete this;
}
