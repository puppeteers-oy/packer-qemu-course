#!/bin/sh
#
# https://learn.microsoft.com/en-us/azure/virtual-machines/linux/redhat-create-upload-vhd#rhel-8-using-hyper-v-manager
#
cloud-init clean
waagent -force -deprovision+user
rm -f ~/.bash_history
rm -f /var/log/waagent.log
export HISTSIZE=0
