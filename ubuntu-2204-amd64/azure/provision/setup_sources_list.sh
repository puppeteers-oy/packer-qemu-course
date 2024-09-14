#!/bin/sh
#
# Set up sources.list for Azure
#
sed -i 's#http://archive\.ubuntu\.com/ubuntu#http://azure\.archive\.ubuntu\.com/ubuntu#g' /etc/apt/sources.list
sed -i 's#http://[a-z][a-z]\.archive\.ubuntu\.com/ubuntu#http://azure\.archive\.ubuntu\.com/ubuntu#g' /etc/apt/sources.list
sed -i 's#http://security\.ubuntu\.com/ubuntu#http://azure\.archive\.ubuntu\.com/ubuntu#g' /etc/apt/sources.list
sed -i 's#http://[a-z][a-z]\.security\.ubuntu\.com/ubuntu#http://azure\.archive\.ubuntu\.com/ubuntu#g' /etc/apt/sources.list
apt-get update
