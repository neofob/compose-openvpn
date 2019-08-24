Quickly spin up openvpn server with docker using docker-compose
===============================================================
This is based on [`kylemanna/openvpn`][0] docker image. See
their [*documents*][1] on how to setup the keys and what not.


All default settings are in [`default_settings.env`][2].
Run `docker-compose config` to review them.


Using `Makefile` for convenience
==============================
  * Setup the environment
    * Create volume
    * Create password file
    * Generate config
  * Generate server files
    * Save server files
    * Load server files
  * Generate client file(s)
    * Get client file(s)
  * List clients


Setup the environment
=====================
```
$ make env
```
**Note:** A generated random password is saved to CWD file `ovpn_passwd.txt`. You should
move it a safe place. You should set the environment `OVPN_PASSWD` to
`/tmp/ovpn_passwd.txt` of which `/tmp` is mounted as `tmpfs`.

Generate server files
=====================
```
$ make server
```
**Save server files**
```
$ make save_server
```
**Load server files**
```
$ make load_server
```

Generate client file(s)
=======================
```
# default client vagrant
$ make client

# generate a different client
$ make OVPN_CLIENT=mickey client
```
**Get client file(s)**
```
# get default client
$ make get_client

# get a specific client
$ make OVPN_CLIENT=mickey get_client
```

__author__: *tuan t. pham*


[0]: https://github.com/kylemanna/docker-openvpn
[1]: https://github.com/kylemanna/docker-openvpn/tree/master/docs
[2]: ./default_settings.env
