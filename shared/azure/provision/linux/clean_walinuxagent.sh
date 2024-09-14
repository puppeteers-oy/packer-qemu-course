#!/bin/sh
#
# https://learn.microsoft.com/en-us/azure/virtual-machines/linux/create-upload-ubuntu
#
systemctl stop walinuxagent.service
rm -rf /var/lib/waagent/
rm -f /var/log/waagent.log
