#!/bin/sh
#
# https://learn.microsoft.com/en-us/azure/virtual-machines/linux/create-upload-ubuntu
#
DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y install gdisk netplan.io walinuxagent && systemctl stop walinuxagent

# walinuxagent will complain in logs if it does not find iptables, even if we
# don't want it to manage the firewall. Also install other walinuxagent
# dependencies even if they're only (possibly) needed for certain Azure
# operations.
apt-get -y install iptables parted

# Copy custom configuration file
cp -v /tmp/waagent.conf /etc/waagent.conf
