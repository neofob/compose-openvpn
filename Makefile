# A wrapper to generate server/client keys
#
# __author__: tuan t. pham

# Load environment settings
include .env
include .makefile_rc

env: volume passwd genconfig

volume:
	docker volume create ${OVPN_DATA}

passwd:
	./genpass.sh > ${OVPN_PASSWD}

genconfig:
	docker run --net=none --rm -it \
		-e OVPN_RNDFILE=/dev/random \
		-v ${OVPN_DATA}:/etc/openvpn \
		${OVPN_IMG}:${OVPN_TAG} ovpn_genconfig \
		-C '${OVPN_CIPHER}' \
		-a '${OVPN_AUTH}' \
		-z \
		-u ${OVPN_PROTO}://${OVPN_RHOST}:${OVPN_RPORT}

gen_rand:
	docker run --net=none --rm -it \
		-v ${OVPN_DATA}:/etc/openvpn \
		--entrypoint /bin/sh \
		${OVPN_IMG}:${OVPN_TAG} \
		-c "mkdir /etc/openvpn/pki && /bin/dd if=/dev/random of=/etc/openvpn/pki/.rnd bs=256 count=1"

server:
	docker run -e EASYRSA_KEY_SIZE=${OVPN_KEY_SIZE} \
		-v ${OVPN_DATA}:/etc/openvpn \
		--rm -it \
		${OVPN_IMG}:${OVPN_TAG} \
		ovpn_initpki

save_server:
	docker run -e EASYRSA_KEY_SIZE=${OVPN_KEY_SIZE} \
		-v ${OVPN_DATA}:/etc/openvpn \
		--rm -it ${OVPN_IMG}:${OVPN_TAG} \
		ovpn_copy_server_files
	docker run -v ${OVPN_DATA}:/etc/openvpn \
		--rm ${OVPN_IMG}:${OVPN_TAG} \
		tar -cvf - -C /etc/openvpn/server . \
		| xz > ${OVPN_SERVER_FILE}

load_server:
	xzcat ${OVPN_SERVER_FILE} | \
	docker run -v ${OVPN_DATA}:/etc/openvpn \
		--rm -i ${OVPN_IMG}:${OVPN_TAG} \
		tar -xvf - -C /etc/openvpn

client:
	docker run -e EASYRSA_KEY_SIZE=${OVPN_KEY_SIZE} \
		-v ${OVPN_DATA}:/etc/openvpn \
		--rm -it \
		${OVPN_IMG}:${OVPN_TAG} \
		easyrsa build-client-full ${OVPN_CLIENT} nopass

get_client:
	docker run -e EASYRSA_KEY_SIZE=${OVPN_KEY_SIZE} \
		-v ${OVPN_DATA}:/etc/openvpn \
		--rm -it \
		${OVPN_IMG}:${OVPN_TAG} \
		ovpn_getclient ${OVPN_CLIENT} > ${OVPN_CLIENT}.ovpn

list:
	docker run \
		-v ${OVPN_DATA}:/etc/openvpn \
		--log-driver=none \
		--rm \
		${OVPN_IMG}:${OVPN_TAG} \
		ovpn_listclients

help:
	@echo	"A simple Makefile to speedup openvpn keys generating and deploying."
	@echo	"\033[1;31mAvailable targets:\033[0m"
	@echo
	@echo	"\033[1;31mhelp:\033[0m"
	@echo	"\tThis help message"
	@echo
	@echo	"\033[1;31menv:\033[0m"
	@echo	"\tSetup the environment before generating server/client keys with these:"
	@echo	"\t* Docker volume '$(OVPN_DATA)'"
	@echo	"\t* Random password for self-signed cert in '$(OVPN_PASSWD)'"
	@echo	"\t* Generate default config in docker volume  '$(OVPN_DATA)'"

dump_env:
	@echo	"Dump environment variables:"
	@echo	"OVPN_IMG=$(OVPN_IMG)"
	@echo	"OVPN_TAG=$(OVPN_TAG)"
	@echo	"OVPN_DATA=$(OVPN_DATA)"
	@echo	"OVPN_PASSWD=$(OVPN_PASSWD)"
	@echo	"OVPN_CIPHER=$(OVPN_CIPHER)"

	@echo	"OVPN_AUTH=$(OVPN_AUTH)"
	@echo	"OVPN_PROTO=$(OVPN_PROTO)"
	@echo	"OVPN_CN=$(OVPN_CN)"
	@echo	"OVPN_RHOST=$(OVPN_RHOST)"
	@echo	"OVPN_RPORT=$(OVPN_RPORT)"

	@echo	"OVPN_CLIENT=$(OVPN_CLIENT)"
	@echo	"OVPN_KEY_SIZE=$(OVPN_KEY_SIZE)"
	@echo	"OVPN_SERVER_FILE=$(OVPN_SERVER_FILE)"
