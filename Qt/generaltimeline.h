#ifndef GENERALTIMELINE_H
#define GENERALTIMELINE_H

#include "QTimeLine"
class GeneralTimeLine : public QTimeLine
{
    Q_OBJECT
public:
    int picIndex;
    GeneralTimeLine(int t);
public slots:
    void DoWhenStop(QTimeLine::State s);
    void DoWhenF();

};

#endif // GENERALTIMELINE_H
