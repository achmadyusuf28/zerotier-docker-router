#!/bin/bash

# Enable IPv4 forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# Start the ZeroTier daemon
zerotier-one &

# Wait for ZeroTier to fully initialize (give it a few seconds)
sleep 5

# Join the specified ZeroTier network ID.
if [ -z "$1" ]; then
  echo "Error: No ZeroTier network ID provided!"
  exit 1
else
  # Join the ZeroTier network
  zerotier-cli join "$1"
  echo "Joined ZeroTier network $1"
fi

# Fetch ZeroTier network interface name dynamically (usually starts with zt)
ZT_INTERFACE=$(ip link | grep zt | awk -F: '{print $2}' | xargs)

# Docker internal network interface (usually eth0)
DOCKER_INTERFACE="eth0"

# Check if ZeroTier interface exists before applying rules.
if [ -n "$ZT_INTERFACE" ]; then
  echo "Setting up iptables rules for forwarding traffic between $DOCKER_INTERFACE and $ZT_INTERFACE"

  # NAT traffic going out Docker interface
  iptables -t nat -A POSTROUTING -o $DOCKER_INTERFACE -j MASQUERADE

  # Allow forwarding traffic between the two networks (Docker <-> ZeroTier)
  iptables -A FORWARD -i $DOCKER_INTERFACE -o $ZT_INTERFACE -j ACCEPT
  iptables -A FORWARD -i $ZT_INTERFACE -o $DOCKER_INTERFACE -m state --state RELATED,ESTABLISHED -j ACCEPT

else
  echo "Error: ZeroTier network interface was not found."
  exit 1
fi

# Keep the script running by waiting for the ZeroTier daemon
wait