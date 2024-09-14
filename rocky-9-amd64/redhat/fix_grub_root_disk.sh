#!/bin/sh
#
grubby --update-kernel=ALL --args="root=LABEL=Root"
grubby --info=DEFAULT
grub2-mkconfig -o /boot/grub2/grub.cfg
