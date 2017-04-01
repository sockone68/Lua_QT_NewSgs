#ifndef LUAWAKER_H
#define LUAWAKER_H

#include <QObject>

class LuaWaker : public QObject
{
    Q_OBJECT
public:
    explicit LuaWaker(QObject *parent = 0);

protected:
    void timerEvent(QTimerEvent *event);
private:
    int myTimerId;
signals:

public slots:
    void wake(int milis);
};

#endif // LUAWAKER_H
