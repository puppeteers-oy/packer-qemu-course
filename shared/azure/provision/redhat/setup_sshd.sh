#!/bin/sh
#
# https://learn.microsoft.com/en-us/azure/virtual-machines/linux/redhat-create-upload-vhd#rhel-8-using-hyper-v-manager
#
sed -i s/"\#ClientAliveInterval .*"/"ClientAliveInterval 180"/g /etc/ssh/sshd_config
