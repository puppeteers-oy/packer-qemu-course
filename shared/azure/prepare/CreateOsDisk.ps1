param(
    [Parameter(Mandatory)]
    [string]$SubscriptionId,
    [Parameter(Mandatory)]
    [string]$Location,
    [Parameter(Mandatory)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory)]
    [string]$StorageAccountName,
    [string]$StorageContainerName = 'vhd',
    [Parameter(Mandatory)]
    [string]$DiskBaseName,
    [Parameter(Mandatory)]
    [string]$DiskRevision,
    [Parameter(Mandatory)]
    [string]$DiskSize,
    [string]$DiskSkuName = 'Standard_LRS',
    [string]$OsType = 'Linux',
    [String]$HyperVGeneration = 'V2'
)

<#
.SYNOPSIS
    Create a managed Azure disk from a VHD file.

.DESCRIPTION
    Create a managed Azure disk from a VHD file. This script is a parameterized
    version of this upstream script:

      https://github.com/Azure-Samples/managed-disks-powershell-getting-started/blob/master/CreateManagedDiskFromVHD.ps1
#>

$DiskName = "${DiskBaseName}-${DiskRevision}" 
$DiskSize = "${DiskSize}"
$VhdUri = "https://${StorageAccountName}.blob.core.windows.net/${StorageContainerName}/${DiskName}.vhd"
$StorageAccountId = "/subscriptions/${SubscriptionId}/resourceGroups/${ResourceGroupName}/providers/Microsoft.Storage/storageAccounts/${StorageAccountName}"

Write-host "Input parameters:"
Write-Host "  Subscription ID: ${SubscriptionId}"
Write-Host "  Location: ${Location}"
Write-Host "  Resource group name: ${ResourceGroupName}"
Write-Host "  Storage Account Name: ${StorageAccountName}"
Write-Host "  Storage Container Name: ${StorageContainerName}"
Write-Host "  Disk basename: ${DiskBaseName}"
Write-Host "  Disk revision: ${DiskRevision}"
Write-Host "  Disk size (GB): ${DiskSize}"
Write-Host "  Disk SKU name: ${DiskSkuName}"
Write-Host "  OS type: ${OsType}"
Write-Host "  Hyper-V generation: ${HyperVGeneration}"
Write-Host
Write-Host "Constructed parameters:"
Write-Host "  Disk name: ${DiskName}"
Write-Host "  VHD URI: ${VhdUri}"
Write-Host "  Storage Account ID: ${StorageAccountId}"
Write-Host

# Set the context to the subscription Id where Managed Disk will be created
Set-AzContext -Subscription $SubscriptionId

# If you're creating an OS disk, add -HyperVGeneration and -OSType parameters
$DiskConfig = New-AzDiskConfig -SkuName $DiskSkuName -Location $Location -OSType $OsType -DiskSizeGB $DiskSize -SourceUri $VhdUri -StorageAccountId $StorageAccountId -CreateOption Import

# Create Managed disk
New-AzDisk -DiskName $DiskName -Disk $DiskConfig -ResourceGroupName $ResourceGroupName
