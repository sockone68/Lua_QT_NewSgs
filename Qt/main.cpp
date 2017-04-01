
#include "QQmlApplicationEngine"
#include "mainwindow.h"
#include <QApplication>
#include "gamethread.h"
MainWindow* mw;
#include "qfile.h"
QFile *file;
 QTextStream* out;
 QDir dir;
     QQmlApplicationEngine* engine=0;
#define themac
     void createNewFile();
int main(int argc, char *argv[])
{


   QApplication a(argc, argv);
    MainWindow w;mw=&w;
qDebug()<<"threadid:"<<QThread::currentThreadId();
    w.show();

    qDebug()<<dir.currentPath();
    qDebug()<<QCoreApplication::applicationDirPath ();
    QDir::setCurrent(QCoreApplication::applicationDirPath ());
    qDebug()<<dir.currentPath();
    createNewFile();

    return a.exec();
}
#include "QTime"
void createNewFile(){
    srand(time(NULL));
    file=new QFile(dir.currentPath()+QString("/logs/NbSGSLog_%1.txt").arg(QTime::currentTime().toString("hh:mm:ss.zzz")));
    out=new QTextStream(file);
    QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    if (!file->open(QIODevice::WriteOnly)) {
        qDebug() << "Cannot open file for writing: "
                  << qPrintable(file->errorString()) << "\n";

    }

}
