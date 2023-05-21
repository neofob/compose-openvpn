#!/usr/bin/env bash

CLIENTS=${CLIENTS:=clients.txt}

for c in $(cat ${CLIENTS}); do
    #echo "OVPN_CLIENT=${c}"
    OVPN_CLIENT=${c} make client
done
