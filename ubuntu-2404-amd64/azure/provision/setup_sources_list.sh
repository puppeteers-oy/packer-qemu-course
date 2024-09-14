#!/bin/sh
#
# Use Azure apt repository mirrors
#
# https://learn.microsoft.com/en-us/azure/virtual-machines/linux/create-upload-ubuntu
#
# Modified for Ubuntu 24.04 which no longer uses sources.list
#
sed -i 's#http://archive\.ubuntu\.com/ubuntu#http://azure\.archive\.ubuntu\.com/ubuntu#g' /etc/apt/sources.list.d/ubuntu.sources
sed -i 's#http://[a-z][a-z]\.archive\.ubuntu\.com/ubuntu#http://azure\.archive\.ubuntu\.com/ubuntu#g' /etc/apt/sources.list.d/ubuntu.sources
sed -i 's#http://security\.ubuntu\.com/ubuntu#http://azure\.archive\.ubuntu\.com/ubuntu#g' /etc/apt/sources.list.d/ubuntu.sources
sed -i 's#http://[a-z][a-z]\.security\.ubuntu\.com/ubuntu#http://azure\.archive\.ubuntu\.com/ubuntu#g' /etc/apt/sources.list.d/ubuntu.sources
apt-get update
