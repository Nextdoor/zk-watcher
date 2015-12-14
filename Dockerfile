FROM odise/busybox-python:2015.02
MAINTAINER Matt Wise <matt@nextdoor.com>

RUN mkdir /app /app/zk_watcher

ADD requirements.txt /app
ADD requirements.test.txt /app
ADD setup.py /app
ADD README.rst /app
ADD zk_watcher /app/zk_watcher

RUN cd /app; python setup.py install
