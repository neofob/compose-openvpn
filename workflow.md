A brief note on generate keys and all
=====================================
*Use `make` workflow in README.md to speed up the process*

* Generating server key
* Generating client key
* Save files for server
* Get client key
* Finetune client key
* Load server files

Setting up the environment
==========================
```
$ export OVPN_DATA=openvpn-data
$ export OVPN_IMG=kylemanna/openvpn
$ docker volume create $OVPN_DATA
# Random password is generated, saved to passwd.txt, copied to clipboard
# You will need this later in generate server key, client key
$ openssl rand -base64 $(echo $RANDOM%8+24 | bc) | tee > passwd.txt | xclip -selection c
$ docker run --net=none --rm -it \
              -v $OVPN_DATA:/etc/openvpn \
              $OVPN_IMG ovpn_genconfig \
              -C 'AES-256-CBC' -a 'SHA384' -z -u udp://remote_ip:8080
```
Note:
* `remote_ip`: the ip where your server will run and reachable by client
* `8080`: use any port that you will publish instead of default 1194

Generate server key
===================
```
docker run -e EASYRSA_KEY_SIZE=4096 -v $OVPN_DATA:/etc/openvpn --rm -it $OVPN_IMG ovpn_initpki
```


Save files for server
=====================
```
docker run -e EASYRSA_KEY_SIZE=4096 \
            -v $OVPN_DATA:/etc/openvpn \
            --rm -it $OVPN_IMG \
            ovpn_copy_server_files

docker run -v $OVPN_DATA:/etc/openvpn \
            --rm $OVPN_IMG \
            tar -cvf - -C /etc/openvpn/server . \
            | xz > server.tar.xz

```

Restore server files to docker volume
=====================================
```
xzcat server.tar.xz | \
docker run -v $OVPN_DATA:/etc/openvpn \
            --rm -i $OVPN_IMG \
            tar -xvf - -C /etc/openvpn
```

Generate client key
===================
```
docker run -e EASYRSA_KEY_SIZE=4096 \
            -v $OVPN_DATA:/etc/openvpn \
            --rm -it $OVPN_IMG easyrsa build-client-full vagrant nopass
```

Get client key
==============
```
docker run -v $OVPN_DATA:/etc/openvpn \
            --log-driver=none \
            --rm $OVPN_IMG ovpn_getclient vagrant > vagrant.ovpn
```

List clients
============
```
docker run -v $OVPN_DATA:/etc/openvpn --log-driver=none --rm $OVPN_IMG ovpn_listclients
```
