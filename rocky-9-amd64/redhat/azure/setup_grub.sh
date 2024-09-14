#!/bin/sh
#
# Use grubby to change partition references in /boot/grub2/grub.cfg from UUIDs to LABELs. This
# depends on the partition labels getting set in the kickstart file.
#
grubby --update-kernel=ALL --remove-args="root"
grubby --update-kernel=ALL --remove-args="resume"
grubby --update-kernel=ALL --args="ro rootdelay=300 console=ttyS0 earlyprintk=ttyS0 no_timer_check net.ifnames=0 crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M"
grub2-mkconfig -o /boot/grub2/grub.cfg
