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

# Add these if you need to customize
# -s subnet
# -r routing
genconfig:
	docker run --rm \
		--net=none \
		--log-driver=none \
		-v ${OVPN_DATA}:/etc/openvpn \
		${OVPN_IMG}:${OVPN_TAG} ovpn_genconfig \
		-C '${OVPN_CIPHER}' \
		-a '${OVPN_AUTH}' \
		-n '${OVPN_DNS}' \
		-r '192.168.42.0/24' \
		-z \
		-u ${OVPN_PROTO}://${OVPN_RHOST}:${OVPN_RPORT}

server:
	docker run \
		--net=none \
		--log-driver=none \
		-e EASYRSA_KEY_SIZE=${OVPN_KEY_SIZE} \
		-v ${OVPN_DATA}:/etc/openvpn \
		--rm -it \
		${OVPN_IMG}:${OVPN_TAG} \
		ovpn_initpki

save_server:
	docker run \
		--net=none \
		--log-driver=none \
		-v ${OVPN_DATA}:/etc/openvpn \
		--rm -it ${OVPN_IMG}:${OVPN_TAG} \
		ovpn_copy_server_files
	docker run -v ${OVPN_DATA}:/etc/openvpn \
		--net=none \
		--log-driver=none \
		--rm ${OVPN_IMG}:${OVPN_TAG} \
		tar -cvf - -C /etc/openvpn/server . \
		| xz > ${OVPN_SERVER_FILE}

load_server:
	xzcat ${OVPN_SERVER_FILE} | \
	docker run -v ${OVPN_DATA}:/etc/openvpn \
		--net=none \
		--log-driver=none \
		--rm -i ${OVPN_IMG}:${OVPN_TAG} \
		tar -xvf - -C /etc/openvpn

client:
	docker run -e EASYRSA_KEY_SIZE=${OVPN_KEY_SIZE} \
		--net=none \
		--log-driver=none \
		-v ${OVPN_DATA}:/etc/openvpn \
		--rm -it \
		${OVPN_IMG}:${OVPN_TAG} \
		easyrsa build-client-full ${OVPN_CLIENT} nopass

get_client:
	docker run -v ${OVPN_DATA}:/etc/openvpn \
		--net=none \
		--log-driver=none \
		--rm -it \
		${OVPN_IMG}:${OVPN_TAG} \
		ovpn_getclient ${OVPN_CLIENT} > ${OVPN_OUTPUT_DIR}/${OVPN_CLIENT}.ovpn

get_all:
	@echo "Get all clients (written to /etc/openvpn/clients in ${OVPN_DATA}"
	docker run -v ${OVPN_DATA}:/etc/openvpn \
		--net=none \
		--log-driver=none \
		--rm -it \
		${OVPN_IMG}:${OVPN_TAG} \
		ovpn_getclient_all
list:
	docker run -v ${OVPN_DATA}:/etc/openvpn \
		--net=none \
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
	@echo	"\tSetup the environment before generating server/client keys with these targets:"
	@echo	"\t* volume: Docker volume '$(OVPN_DATA)'"
	@echo	"\t* passwd: Random password for self-signed cert in '$(OVPN_PASSWD)'"
	@echo	"\t* genconfig: Generate default config in docker volume  '$(OVPN_DATA)'"
	@echo
	@echo	"\033[1;31mvolume:\033[0m"
	@echo	"\tCreate openvpn data volume"
	@echo	"\t* Default volume '$(OVPN_DATA)'"
	@echo
	@echo	"\033[1;31mpasswd:\033[0m"
	@echo	"\tGenerate random password to '$(OVPN_PASSWD)'"
	@echo
	@echo	"\033[1;31mgenconfig:\033[0m"
	@echo	"\tGenerate initial config"
	@echo
	@echo	"\033[1;31mserver:\033[0m"
	@echo	"\tGenerate server key"
	@echo
	@echo	"\033[1;31msave_server:\033[0m"
	@echo	"\tSave necessary server files to '$(OVPN_SERVER_FILE)'"
	@echo
	@echo	"\033[1;31mload_server:\033[0m"
	@echo	"\tLoad server config files from '$(OVPN_SERVER_FILE)'"
	@echo
	@echo	"\033[1;31mclient:\033[0m"
	@echo	"\tGenerate a client key, default name '$(OVPN_CLIENT)'"
	@echo	"\tCustom name:"
	@echo	"\tmake OVPN_CLIENT=custom_name client"
	@echo
	@echo	"\033[1;31mget_client:\033[0m"
	@echo	"\tGet client to '$(PWD)/$(OVPN_CLIENT).ovpn'"
	@echo	"\tCustom name:"
	@echo	"\tmake OVPN_CLIENT=custom_name get_client"
	@echo
	@echo	"\033[1;31mlist:\033[0m"
	@echo	"\tList available client keys"
	@echo
	@echo	"\033[1;31mdump_env:\033[0m"
	@echo	"\tDump environment settings"
	@echo
	@echo	"__author__: tuan t. pham"

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

	@echo	"OVPN_OUTPUT_DIR=$(OVPN_OUTPUT_DIR)"
	@echo	"OVPN_CLIENT=$(OVPN_CLIENT)"
	@echo	"OVPN_KEY_SIZE=$(OVPN_KEY_SIZE)"
	@echo	"OVPN_SERVER_FILE=$(OVPN_SERVER_FILE)"

rm_env: rm_volume rm_passwd

rm_volume:
	docker volume rm ${OVPN_DATA}

rm_passwd:
	rm ${OVPN_PASSWD}
