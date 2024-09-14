#!/bin/sh
#
# https://learn.microsoft.com/en-us/azure/virtual-machines/linux/redhat-create-upload-vhd
#

# add_drivers is not enough - the modules get added to initrd, but are
# not loeaded automatically
echo "force_drivers+=\" hv_vmbus hv_netvsc hv_storvsc \"" > /etc/dracut.conf.d/80-azure.conf

dracut -f -v
