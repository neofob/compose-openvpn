#!/bin/env bash
# Model: gemma4:26b

# Generate a list of client, static ip pool for openvpn server
# Option for openvpn server (/etc/openvpn/openvpn.conf)
# ifconfig-pool-persist /etc/openvpn/clients.txt

# Ensure environment variables are provided
if [[ -z "$CLIENT_LIST" ]] || [[ -z "$START_IP" ]]; then
    echo "Error: Environment variables CLIENT_LIST and START_IP must be set."
    echo "Usage: CLIENT_LIST='clients.txt' START_IP='192.168.26.2' $0"
    exit 1
fi

# Ensure the client list file exists
if [[ ! -f "$CLIENT_LIST" ]]; then
    echo "Error: File '$CLIENT_LIST' not found."
    exit 1
fi

# Function to increment an IPv4 address
increment_ip() {
    local ip=$1
    local IFS=.
    read -r a b c d <<< "$ip"

    d=$((d + 1))
    if ((d > 255)); then
        d=0
        c=$((c + 1))
        if ((c > 255)); then
            c=0
            b=$((b + 1))
            if ((b > 255)); then
                b=0
                a=$((a + 1))
            fi
        fi
    fi
    echo "$a.$b.$c.$d"
}

# Read clients into an array, stripping carriage returns and whitespace
mapfile -t clients < <(sed 's/\r//g' "$CLIENT_LIST" | sed '/^[[:space:]]*$/d')
total_clients=${#clients[@]}

if [[ $total_clients -eq 0 ]]; then
    echo "Error: Client list is empty."
    exit 1
fi

current_ip="$START_IP"

# Iterate through clients and generate the list
for (( i=0; i<total_clients; i++ )); do
    client="${clients[$i]}"

    # Remove any leading/trailing whitespace from the client name
    client=$(echo "$client" | xargs)

    if [[ $i -eq $((total_clients - 1)) ]]; then
        # Last element: no trailing comma as per example
        printf "%s,%s\n" "$client" "$current_ip"
    else
        # Intermediate elements: trailing comma as per example
        printf "%s,%s,\n" "$client" "$current_ip"
    fi

    # Increment the IP for the next iteration
    current_ip=$(increment_ip "$current_ip")
done
