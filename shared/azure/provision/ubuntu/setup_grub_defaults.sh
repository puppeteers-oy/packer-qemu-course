#!/bin/sh
#
# https://learn.microsoft.com/en-us/azure/virtual-machines/linux/create-upload-ubuntu
#
sed -i s/"GRUB_CMDLINE_LINUX_DEFAULT=.*"/"GRUB_CMDLINE_LINUX_DEFAULT=\"console=tty1 console=ttyS0,115200n8 earlyprintk=ttyS0,115200 rootdelay=300 quiet splash\""/g /etc/default/grub

update-grub
