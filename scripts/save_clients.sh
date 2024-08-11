#!/usr/bin/env bash

for client in $(make list | tail  +8 | cut -d "," -f1); do
    echo "Saving config file for $client"
    make OVPN_CLIENT=$client get_client
    echo "script-security 2" >> /tmp/$client.ovpn
    dos2unix /tmp/$client.ovpn
done
