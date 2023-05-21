#!/usr/bin/env bash
openssl rand -base64 $(echo $RANDOM%8+24 | bc)
