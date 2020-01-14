HERE = $(shell pwd)
BIN = $(HERE)/bin

BUILD_DIRS = bin .build build include lib lib64 man share package *.egg

ZOOKEEPER = $(BIN)/zookeeper
ZOOKEEPER_VERSION ?= 3.4.7
ZOOKEEPER_PATH ?= $(ZOOKEEPER)
ZOOKEEPER_URL = https://archive.apache.org/dist/zookeeper/zookeeper-$(ZOOKEEPER_VERSION)/zookeeper-$(ZOOKEEPER_VERSION).tar.gz


.PHONY: all build clean test docs zookeeper clean-zookeeper

all: build

build: .build

.build: requirements.test.txt
	python setup.py install
	pip install -r requirements.test.txt
	touch .build

image:
	docker build -t zkwatcher .

hello-world:
	docker pull tutum/hello-world
	docker rm -f hello-world || echo "No pre-existing container found"
	docker run -d --name hello-world tutum/hello-world

run: hello-world zookeeper
	docker rm -f zkwatcher || echo "No pre-existing container found"
	docker run \
		--name "zkwatcher" \
		--sig-proxy=false \
		--env "ZOOKEEPER_HOST=host.docker.internal" \
		--env "CMD=curl --silent --fail http://hello-world:\$$APACHE_PORT_80_TCP_PORT" \
		--env "SVC_PORT=80" \
		--env "SVC_HOST=hello-world" \
		--env "ZK_PATH=/hello-world" \
		--link "hello-world" \
		zkwatcher

clean:
	find . -type f -name '*.pyc' -exec rm "{}" \;
	rm -rf $(BUILD_DIRS)
	$(MAKE) -C docs clean docs

test: build docs
	python setup.py test pep8 pyflakes

integration: build
	PYFLAKES_NODOCTEST=True python setup.py integration pep8 pyflakes

docs:
	$(MAKE) -C docs html

$(ZOOKEEPER):
	@echo "Installing Zookeeper"
	mkdir -p $(BIN) && cd $(BIN) && curl -C - $(ZOOKEEPER_URL) | tar -zx
	mv $(BIN)/zookeeper-$(ZOOKEEPER_VERSION) $(ZOOKEEPER_PATH)
	chmod a+x $(ZOOKEEPER_PATH)/bin/zkServer.sh
	cp $(ZOOKEEPER_PATH)/conf/zoo_sample.cfg $(ZOOKEEPER_PATH)/conf/zoo.cfg
	@echo "Finished installing Zookeeper"

zookeeper: $(ZOOKEEPER)
	$(ZOOKEEPER_PATH)/bin/zkServer.sh start

clean-zookeeper:
	rm -rf zookeeper $(ZOOKEEPER_PATH)
