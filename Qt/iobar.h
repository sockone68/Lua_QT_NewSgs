#ifndef IOBAR_H
#define IOBAR_H
#include "QTextEdit"

class IOBar:public QTextEdit
{
public:
bool isProgramInputed;

    // QWidget interface
protected:
    void keyReleaseEvent(QKeyEvent *event);

    // QWidget interface
protected:
    void mousePressEvent(QMouseEvent *event);
};

#endif // IOBAR_H
