#!/bin/sh
#
# Install kernel tailored for Azure
#
# https://learn.microsoft.com/en-us/azure/virtual-machines/linux/create-upload-ubuntu
#
DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y install linux-azure linux-image-azure linux-headers-azure linux-tools-common linux-cloud-tools-common linux-tools-azure linux-cloud-tools-azure
