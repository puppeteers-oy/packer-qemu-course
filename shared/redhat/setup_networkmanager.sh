#!/bin/sh
#
# https://learn.microsoft.com/en-us/azure/virtual-machines/linux/redhat-create-upload-vhd#rhel-8-using-hyper-v-manager
#
systemctl enable NetworkManager.service
nmcli con mod ens3 connection.autoconnect yes ipv4.method auto || true
