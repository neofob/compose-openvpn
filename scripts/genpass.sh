#!/usr/bin/env bash
BYTES=$(( RANDOM % 8 + 24 ))
openssl rand -base64 "$BYTES"
