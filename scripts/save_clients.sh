#!/usr/bin/env bash

for client in $(make list | grep "VALID$" | cut -d "," -f1); do
    echo "Saving config file for $client"
    make OVPN_CLIENT=$client get_client
    echo "script-security 2" >> /tmp/$client.ovpn

	# Fine-tune
# mssfix 0
# fast-io
# sndbuf 524288
# rcvbuf 524288
# txqueuelen 2000

	cat <<EOF >> /tmp/$client.ovpn
mssfix 0
fast-io
sndbuf 524288
rcvbuf 524288
txqueuelen 2000
EOF

    dos2unix /tmp/$client.ovpn
done
