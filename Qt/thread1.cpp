#include "thread1.h"

#include "mainwindow.h"

#include "gamethread.h"

Thread1::Thread1()
{

}

void Thread1::run()
{
    mw->gm->call("resumeXc");
}
