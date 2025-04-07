#!/usr/bin/env bash

CLIENTS=${CLIENTS:=clients.txt}
PASSWD=${PASSWD:-/tmp/ovpn_passwd.txt}

echo "yes" > /tmp/answers.txt
cat $PASSWD >> /tmp/answers.txt

for c in $(cat ${CLIENTS}); do
    #echo "OVPN_CLIENT=${c}"

    cat /tmp/answers.txt | OVPN_CLIENT=${c} make client
done
