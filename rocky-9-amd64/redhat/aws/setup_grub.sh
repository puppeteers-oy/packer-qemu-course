#!/bin/sh
#
# Use grubby to change partition references in /boot/grub2/grub.cfg from UUIDs to LABELs. This
# depends on the partition labels getting set in the kickstart file.
#
grubby --update-kernel=ALL --remove-args="root"
grubby --update-kernel=ALL --remove-args="resume"
grubby --update-kernel=ALL --args="console=ttyS0,115200n8 no_timer_check crashkernel=auto net.ifnames=0 nvme_core.io_timeout=4294967295 nvme_core.max_retries=10 "
grub2-mkconfig -o /boot/grub2/grub.cfg
