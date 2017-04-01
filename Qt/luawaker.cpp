#include "luawaker.h"
#include "QTimerEvent"
#include "thread1.h"
LuaWaker::LuaWaker(QObject *parent) : QObject(parent)
{

}

void LuaWaker::wake(int milis)
{
    myTimerId=startTimer(milis);
}

void LuaWaker::timerEvent(QTimerEvent *event)
{
    if (event->timerId() == myTimerId) {
          Thread1* t1=new Thread1();
          t1->start();

      }
}
