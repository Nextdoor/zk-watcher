Zookeeper Watcher Daemon Docs
=============================

About
=====

`zk_watcher` is a Python script that registers
`Ephemeral Nodes <http://zookeeper.apache.org/doc/current/zookeeperProgrammers.html#Ephemeral+Nodes>`__
in Apache Zookeeper based on the result of a healthcheck.

The goal of `zk_watcher` is to monitor a particular service on a host machine
and register that machine as a `provider` of that service at a given path
on the Zookeeper service.

A simple example is having `zk_watcher` monitor Apache httpd by running `service
apache2 status` at a regular interval and registers with ZooKeeper at a given
path (say `/services/production/webservers`). As long as the command returns
a safe exit code (`0`), `zk_watcher` will register with ZooKeeper that this
server is providing this particular service. If the hostname of the machine
is `web1.mydomain.com`, the registration path would look like this ::

    /services/production/webservers/web1.mydomain.com:80

In the event that the service check fails, the host will be immediately de-
registered from that path.

.. toctree::
   :maxdepth: 3

   install
   config
   auth
   running

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

=========
