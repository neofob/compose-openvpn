#!/bin/sh
# Add "auth-nocache" to config files
# ./add_nocache.sh ovpn_dir
if [ ! -d $1 ]; then
    echo "Directory $1 does not exist"
    exit 1
fi

for f in `ls $1/*.ovpn`; do echo "auth-nocache" >> $f; done
