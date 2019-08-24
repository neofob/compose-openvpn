# A wrapper to generate server/client keys
#
# __author__: tuan t. pham

OVPN_IMG ?=kylemanna/openvpn
#OVPN_IMG ?=neofob/openvpn
OVPN_TAG ?=latest

OVPN_DATA ?=openvpn-data
OVPN_PASSWD ?=ovpn_passwd.txt
OVPN_CIPHER ?=AES-256-CBC
OVPN_AUTH ?=SHA384
OVPN_PROTO ?=udp
# Common Name
OVPN_CN ?=neofob.info

# Set this to your remote openvpn host
OVPN_RHOST ?=openvpn.local
OVPN_RPORT ?=443
OVPN_CLIENT ?=vagrant

OVPN_KEY_SIZE ?=4096


env: volume passwd genconfig

volume:
	docker volume create ${OVPN_DATA}

passwd:
	./genpass.sh > ${OVPN_PASSWD}

genconfig:
	docker run --net=none --rm -it \
		-v ${OVPN_DATA}:/etc/openvpn \
		${OVPN_IMG}:${OVPN_TAG} ovpn_genconfig \
		-C '${OVPN_CIPHER}' \
		-a '${OVPN_AUTH}' \
		-z \
		-u ${OVPN_PROTO}://${OVPN_RHOST}:${OVPN_RPORT}

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
		| xz > server.tar.xz

load_server:
	xzcat server.tar.xz | \
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
