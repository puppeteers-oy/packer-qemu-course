#!/bin/bash
#
# https://learn.microsoft.com/en-us/azure/virtual-machines/linux/create-upload-generic?branch=pr-en-us-185925
#
if [ "$1" = "" ] || [ "$2" = "" ]; then
    echo "Usage: round_disk_size.sh <raw-image> <vhd-image>"
    exit 1
fi

rawdisk=$1
vhddisk=$2

echo "Raw disk: ${rawdisk}"
echo "VHD disk: ${vhddisk}"

# Exit if the image has already been resized and converted to vhd
if [ -f $vhddisk ]; then
  echo "Disk image already resized and converted to VHD"
  exit 0
fi

MB=$((1024*1024))
size=$(qemu-img info -f raw --output json "$rawdisk" | \
gawk 'match($0, /"virtual-size": ([0-9]+),/, val) {print val[1]}')

rounded_size=$(((($size+$MB-1)/$MB)*$MB))

echo "Rounded Size = $rounded_size"

qemu-img resize -f raw $rawdisk $rounded_size
qemu-img convert -f raw -o subformat=fixed,force_size -O vpc $rawdisk $vhddisk
