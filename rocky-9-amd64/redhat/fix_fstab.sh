#!/bin/sh
#
# Remove hardcoded UUIDs from /etc/fstab. They will not work when the disk is
# used in Azure. This depends on disk labels being set accordingly in the
# kickstart file.
#
echo "Removing hardcoded UUIDs from /etc/fstab"

sed -i s/"^UUID=.* \/boot "/"LABEL=Boot \/boot "/g /etc/fstab
sed -i s/"^UUID=.* \/ "/"LABEL=Root \/ "/g /etc/fstab
cat /etc/fstab
