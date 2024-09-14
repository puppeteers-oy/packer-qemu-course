#!/bin/sh
#
# This script prepares the Packer-generated image for Azure



test -f qemu.pkr.hcl  || (echo "ERROR: must run from Packer project directory"; exit 1)
test -f ../azure.vars || (echo "ERROR: azure.vars not found in Git repo root directory"; exit 1)

. ../azure.vars

if [ "${1}" = "" ]; then
    echo "ERROR: must define revision as the first positional parameter!"
    exit 1
fi

DISK_REVISION=$1

LOCAL_RAW_FILE_PATH=$(find build/azure -name "*.raw")
LOCAL_VHD_FILE_PATH=$(echo $LOCAL_RAW_FILE_PATH|sed -E s/".raw$"/".vhd"/g)
DISK_BASENAME=$(basename -s .raw $LOCAL_RAW_FILE_PATH)

../shared/azure/prepare/round_disk_size.sh $LOCAL_RAW_FILE_PATH $LOCAL_VHD_FILE_PATH

pwsh -Command "Connect-AzAccount -SubscriptionId $SUBSCRIPTION_ID"

pwsh -Command "Add-AzVhd -ResourceGroupName $RESOURCE_GROUP_NAME -Destination \"https://${STORAGE_ACCOUNT_NAME}.blob.core.windows.net/vhd/${DISK_BASENAME}-${DISK_REVISION}.vhd\" -LocalFilePath $LOCAL_VHD_FILE_PATH"

pwsh -Command "../shared/azure/prepare/CreateOsDisk.ps1 -SubscriptionId $SUBSCRIPTION_ID -ResourceGroupName $RESOURCE_GROUP_NAME -StorageAccountName $STORAGE_ACCOUNT_NAME -DiskBaseName $DISK_BASENAME -DiskRevision $DISK_REVISION -DiskSize $DISK_SIZE -Location $LOCATION"
