#!/bin/sh
#
# https://learn.microsoft.com/en-us/azure/virtual-machines/linux/redhat-create-upload-vhd#rhel-8-using-hyper-v-manager
#
yum install -y WALinuxAgent cloud-init cloud-utils-growpart gdisk hyperv-daemons
systemctl enable waagent.service
systemctl enable cloud-init.service

# Copy custom configuration file
cp -v /tmp/waagent.conf /etc/waagent.conf
