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
| OVPN_AUTH       | SHA512 |
| OVPN_CIPHER     | AES-256-GCM |
| OVPN_CLIENT     | vagrant |
| OVPN_CN         | neofob.info |
| OVPN_DATA       | openvpn-8080 |
| OVPN_DNS        | pihole.local |
| OVPN_IMG        | neofob/openvpn |
| OVPN_KEY_SIZE   | 4096 |
| OVPN_PASSWD     | /tmp/ovpn_passwd.txt |
| OVPN_PROTO      | udp |
| OVPN_OUTPUT_DIR | /tmp |
| OVPN_RHOST      | openvpn.local |
| OVPN_RPORT      | 8080 |
| OVPN_SERVER_FILE | /tmp/server.tar.xz |
| OVPN_TAG        | 3.21 |

Helper Scripts
=============
* [`genpass.sh`](./scripts/genpass.sh): generate random password to /tmp
* [`create_client.sh`](./scripts/create_client.sh): create clients from the list in text file; defined in CLIENT env var
* [`save_clients.sh`](./scripts/save_clients.sh): save all clients ovpn files to /tmp; `OVPN_OUTPUT_DIR`

Generate clients from the list `clients.txt`; make sure you have the generated passwd from the step `make env` to paste into terminal
when it asks for it. It is save in the location `OVPN_PASSWD`.
```
CLIENTS=clients.txt ./scripts/create_clients.sh
```

Save all client:
```
make get_all
```

## On static IP for OpenVPN clients
Create a text with filename `clients.txt` and place it at `/etc/openvpn` of the `openvpn` container.
See [`clients-openvpn-example.txt`](./clients-openvpn-example.txt) for example format: `client_name,IP,`
```
# you can docker cp it as following
docker cp clients.txt openvpn:/etc/openvpn/

# or, do it the hacky way
cp clients.txt /var/lib/docker/volumes/openvpn_8080/_data/ 
```
The IP is the IP address that the client will get for `tun0`, which must be in the same subnet at setup.
You could change it by editing `/etc/openvpn/openvpn.conf` of the `openvpn` container.

__author__: *tuan t. pham*

[0]: https://github.com/kylemanna/docker-openvpn
[1]: https://github.com/kylemanna/docker-openvpn/tree/master/docs
[2]: ./default_settings.env
