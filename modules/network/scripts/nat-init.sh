#!/bin/bash
set -euxo pipefail

sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf

IFACE=$(ip -o -4 route show to default | awk '{print $5}')

iptables -t nat -A POSTROUTING -o "$IFACE" -j MASQUERADE
iptables-save > /etc/sysconfig/iptables