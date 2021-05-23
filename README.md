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
**Note:** A generated random password is saved to `/tmp/ovpn_passwd.txt`. You should
move it to a safe place. (preferably, /tmp is `tmpfs`).


Generate server files
=====================
You will be asked for password which is saved from `make env` step. You could paste it here
from `cat /tmp/ovpn_passwd.txt | xclip -selection c`
```
$ make server
```
**Save server files**
```
$ make save_server
```
**Load server files**
On the server machine that will run the openvpn server.
```
# Make sure a volume is created
$ make volume
$ make load_server
```

Generate client file(s)
=======================
You will need to enter the generated password from the `make env` step.
```
# default client vagrant
$ make client

# generate a different client
$ make OVPN_CLIENT=mickey client
```
**Get client file(s)**
```
# get default client set in OVPN_CLIENT env variable
$ make get_client

# get a specific client
$ make OVPN_CLIENT=mickey get_client
```

**Modify client.opvn file to use public ipaddress**
```
remote openvpn.local <port> <protocol> 
==>
remote <ur-public-ip> <port> <protocol>
```

**Start up Openvpn service**
```
docker-compose up -d && docker-compose logs --follow
```

Default Environment Variables
=============================

| `Env Variable`  | `Value` |
|:---------------:|:-------:|
| OVPN_IMG        | kylemanna/openvpn |
| OVPN_TAG        | latest |
| OVPN_DATA       | openvpn-data |
| OVPN_PASSWD     | /tmp/ovpn_passwd.txt |
| OVPN_CIPHER     | AES-256-CBC |
| OVPN_AUTH       | SHA384 |
| OVPN_PROTO      | udp |
| OVPN_CN         | neofob.info |
| OVPN_RHOST      | openvpn.local |
| OVPN_RPORT      | 443 |
| OVPN_CLIENT     | vagrant |
| OVPN_KEY_SIZE   | 4096 |
| OVPN_SERVER_FILE | /tmp/server.tar.xz |


**Footnote:** As of `alpine:3.10.2`, there is a bug that when you run `make server`,
the script/program `easyrsa` in `kylemanna/openvpn` will complain about failing to read
`/etc/openvpn/pki/.rnd`. Build your own `OVPN_IMG` from [`docker-openvpn`][0] with `alpine:3.8`
as your base image.

__author__: *tuan t. pham*

[0]: https://github.com/kylemanna/docker-openvpn
[1]: https://github.com/kylemanna/docker-openvpn/tree/master/docs
[2]: ./default_settings.env
