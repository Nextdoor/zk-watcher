FROM alpine:3.2
MAINTAINER Matt Wise <matt@nextdoor.com>

RUN apk add --update bash python py-pip py-yaml ca-certificates

RUN mkdir /app /app/zk_watcher

ADD requirements.test.txt /app
RUN pip install -r /app/requirements.test.txt
ADD requirements.txt /app
RUN pip install -r /app/requirements.txt

ADD setup.py /app
ADD README.rst /app
ADD zk_watcher /app/zk_watcher
RUN cd /app; python setup.py install

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT "/entrypoint.sh"
