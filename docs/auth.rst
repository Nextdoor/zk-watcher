Authentication
--------------

If you wish to create a Digset authentication token and use that for your
client session with Zookeeper, you can add the settings to the config file
like this ::

    [auth]
    user: username
    password: 123456

If you do this, please look at the `nd_service_registry` docs to understand how
the auth token is used, and what permissions are setup by default.
