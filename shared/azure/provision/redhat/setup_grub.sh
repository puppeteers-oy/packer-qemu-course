#!/bin/sh
#
# https://learn.microsoft.com/en-us/azure/virtual-machines/linux/redhat-create-upload-vhd#rhel-8-using-hyper-v-manager
#
grub2-editenv - unset kernelopts
sed -i s/"GRUB_CMDLINE_LINUX=.*"/"GRUB_CMDLINE_LINUX=\"console=tty1 console=ttyS0,115200n8 earlyprintk=ttyS0,115200 earlyprintk=ttyS0 net.ifnames=0\""/g /etc/default/grub 
sed -i s/"GRUB_TERMINAL_OUTPUT=.*"/"GRUB_TERMINAL_OUTPUT=\"serial console\""/g /etc/default/grub
echo "GRUB_SERIAL_COMMAND=\"serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1\"" >> /etc/default/grub

grub2-mkconfig -o /boot/grub2/grub.cfg
