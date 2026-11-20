#!/bin/bash

if [[ -z "$1" ]]; then
    printf 'Usage: %s DNS_SERVER\n' "$0" >&2
    exit 2
fi

dns_server=$1

check_host_ip() {
    local host=$1
    local expected_ip=$2
    local dns_server=$3

    if [[ -z "$host" || -z "$expected_ip" || -z "$dns_server" ]]; then
        return 2
    fi

    if nslookup "$host" "$dns_server" 2>/dev/null | awk -v expected="$expected_ip" '
        $1 == "Address:" {
            if (!server_address_seen) {
                server_address_seen = 1
                next
            }
            if ($2 == expected) {
                found = 1
            }
        }
        END { exit !found }
    '; then
        printf 'Valid: %s resolves to %s using DNS server %s\n' "$host" "$expected_ip" "$dns_server"
        return 0
    else
        printf 'Invalid: %s does not resolve to %s using DNS server %s\n' "$host" "$expected_ip" "$dns_server"
        return 1
    fi
}

while read -r ip names; do
    [[ -z "$ip" || "$ip" == \#* ]] && continue

    for name in $names; do
        [[ "$name" == \#* ]] && break
        check_host_ip "$name" "$ip" "$dns_server"
    done
done < /etc/hosts
