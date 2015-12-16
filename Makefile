HERE = $(shell pwd)
BIN = $(HERE)/bin

BUILD_DIRS = bin .build build include lib lib64 man share package *.egg

ZOOKEEPER = $(BIN)/zookeeper
ZOOKEEPER_VERSION ?= 3.4.7
ZOOKEEPER_PATH ?= $(ZOOKEEPER)
ZOOKEEPER_URL = http://apache.osuosl.org/zookeeper/zookeeper-$(ZOOKEEPER_VERSION)/zookeeper-$(ZOOKEEPER_VERSION).tar.gz

.PHONY: all build clean test docs zookeeper clean-zookeeper

all: build

build: .build

.build: requirements.test.txt
	python setup.py install
	pip install -r requirements.test.txt
	touch .build

image:
	docker build -t zk_watcher .

run:
	docker rm zk_watcher
	docker run \
		--name "zk_watcher" \
		--env "SERVICE_1_PROTO=http" --env "SERVICE_1_URL=/" --env "SERVICE_1_REFRESH=20" \
		--link "apache:service_1" \
		zk_watcher

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
