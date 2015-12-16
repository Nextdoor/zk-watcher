Service Configs
---------------

To configure, edit the '/etc/zk/config.cfg' file. The file consists of sections
that each point to a particular service you want to monitor and register with
ZooKeeper. An example file is provided, but could look like this ::

    [ssh]
    cmd: /etc/init.d/sshd status
    refresh: 60
    service_port: 22
    service_hostname: 123.234.123.123
    zookeeper_path: /services/ssh
    zookeeper_data: { "foo": "bar", "bah": "humbug" }

    [apache]
    cmd: /etc/init.d/apache status
    refresh: 60
    service_port: 22
    zookeeper_path: /services/web
    zookeeper_data: foo=bar, bah=humbug
