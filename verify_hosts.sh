#!/bin/bash

cat /etc/hosts | while read -r ip names; do

    [[ -z "$ip" || "$ip" == \#* ]] && continue

    for name in $names; do

        [[ "$name" == \#* ]] && break

        dns_ip=$(nslookup "$name" 2>/dev/null |
            awk '/^Name:/{found=1} found && /^Address:/{print $2}')

        if [[ -z "$dns_ip" ]]; then
            echo "Could not resolve $name"
        elif ! echo "$dns_ip" | grep -Fxq "$ip"; then
            echo "Bogus IP for $name in /etc/hosts!"
        fi

    done
done
