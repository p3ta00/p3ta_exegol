#!/bin/bash
# Display network interfaces with their IPs

output=""

# Check VPN (tun0)
vpn_ip=$(ip -o -4 addr show dev tun0 2>/dev/null | awk '{print $4}' | cut -d/ -f1)
if [ -n "$vpn_ip" ]; then
    output="VPN: $vpn_ip"
fi

# Check Ethernet (eth*, eno*, enp*)
eth_ip=$(ip -o -4 addr show 2>/dev/null | grep -E '^[0-9]+:\s+(eth|eno|enp)' | grep -v '127.0.0.1' | head -1 | awk '{print $4}' | cut -d/ -f1)
if [ -n "$eth_ip" ]; then
    if [ -n "$output" ]; then
        output="$output ETH: $eth_ip"
    else
        output="ETH: $eth_ip"
    fi
fi

# Check Wireless (wlan*, wlp*)
wlan_ip=$(ip -o -4 addr show 2>/dev/null | grep -E '^[0-9]+:\s+(wlan|wlp)' | grep -v '127.0.0.1' | head -1 | awk '{print $4}' | cut -d/ -f1)
if [ -n "$wlan_ip" ]; then
    if [ -n "$output" ]; then
        output="$output WLAN: $wlan_ip"
    else
        output="WLAN: $wlan_ip"
    fi
fi

# If nothing found, show down status
if [ -z "$output" ]; then
    echo "down"
else
    echo "$output"
fi
