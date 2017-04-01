#include "iobar.h"
#include "QKeyEvent"
#include "mainwindow.h"
#include "gamethread.h"
#include "thread1.h"

extern MainWindow* mw;
void IOBar::keyReleaseEvent(QKeyEvent *event)
{
    if(event->key()==Qt::Key_Return){
        //mw->testWord("Recived your input");

        // Thread1* t1=new Thread1();
        //t1->start();

        if(mw->gm->isRunning())
            mw->gm->sem.release();
        else
            qDebug()<<"not running";
        //mw->gm->call("resumeXc");
    }
    else
        QTextEdit::keyReleaseEvent(event);
}

void IOBar::mousePressEvent(QMouseEvent *event)
{
    if(isProgramInputed==true){
        mw->testWord("");isProgramInputed=false;

    }
    else
        QTextEdit::mousePressEvent(event);
}
