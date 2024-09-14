# Introduction

This repository contains support materials for the "Creating Cloud images from
scratch with Packer and QEMU" course by [Puppeteers Oy](https://www.puppeteers.net/).

# Contributing

If you encounter any issues using the files in this repository please issue a
pull request or file a bug report.

# Prerequisites

* Packer 1.11.1
* guestfs-tools
* Membership in "libvirt" group

# Mounting virtual machine image files

This requires guestfs-tools:

    $ mkdir -p ~/guestmount/ubuntu-2004-amd64
    $ LIBGUESTFS_BACKEND=direct guestmount -a ubuntu-2004-amd64-qemu-iso-output/ubuntu-2004-amd64-qemu-iso-build -m /dev/sda2 ~/guestmount/ubuntu-2004-amd64/

# Building

Initialize Packer (required only once):

    $ cd <packer-root-dir>
    $ packer init .

Install the operating system and create an image out of it (no provisioning):

    $ packer build -force os-install.pkr.hcl

Build provisioned image for AWS:

    $ packer build -force aws.pkr.hcl

Build provisioned image for Azure:

    $ packer build -force azure.pkr.hcl

# Uploading and converting images in AWS

## Creating an S3 bucket

You need an S3 bucket to store your disk images in. It must be in the same
region as the VMs you intend to create.

## Setting up AWS region and keys

You need to have the following environment variables set:

    AWS_DEFAULT_REGION=<region>
    AWS_SECRET_ACCESS_KEY=<secret-access-key>
    AWS_ACCESS_KEY_ID=<access-key-id>

## IAM permission requirements

You own IAM user, i.e. the one the keys (above) belong to is assumed to have
administrator level access in your AWS account. In practice much more
restricted permissions will do, though. It may be enough to grant full access
to the S3 (for uploading disk images) and AWS (for testing if the images
actually work).

## Create an IAM role for VM Import/Export

AWS uses the VM Import/Export service to convert disk images uploaded to AWS S3
into AMIs. The conversion process happens inside of AWS, so you need to enable
the VM Import/Export service to assume a role in your AWS account. That role then
needs to have enough permissions to run the VM import job. This process is pretty
well documented in [this blog post](https://dev.to/otomato_io/from-iso-to-ami-how-to-create-your-own-custom-ami-5213),
but let's go through the steps here as well.

First create *trust-policy.json*:

```
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Effect": "Allow",
         "Principal": { "Service": "vmie.amazonaws.com" },
         "Action": "sts:AssumeRole",
         "Condition": {
            "StringEquals":{
               "sts:Externalid": "vmimport"
            }
         }
      }
   ]
}
```

The create *role-policy.json*:

```
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect": "Allow",
         "Action": [
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket"
         ],
         "Resource": [
            "arn:aws:s3:::YOUR BUCKET",
            "arn:aws:s3:::YOUR BUCKET/*"
         ]
      },
      {
         "Effect": "Allow",
         "Action": [
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:PutObject",
            "s3:GetBucketAcl"
         ],
         "Resource": [
            "arn:aws:s3:::YOUR BUCKET",
            "arn:aws:s3:::YOUR BUCKET/*"
         ]
      },
      {
         "Effect": "Allow",
         "Action": [
            "ec2:ModifySnapshotAttribute",
            "ec2:CopySnapshot",
            "ec2:RegisterImage",
            "ec2:Describe*"
         ],
         "Resource": "*"
      }


   ]
}
```

Now create an IAM role and attach the trust policy to it:

```
aws iam create-role --role-name vmimport --assume-role-policy-document "file://path/to/trust-policy.json"
```

The attach the role policy to the same IAM role:

```
aws iam put-role-policy --role-name vmimport --policy-name vmimport --policy-document "file://path/to/role-policy.json"
```

The *trust policy* allows AWS VM Import/Export service to assume the role it is
attached to. The role name probably *needs* to be *vmimport* or AWS will not
find it.

The *role policy* grants the IAM role (and hence, AWS VM Import/Export service)
the permissions to load VM disk images from the S3 bucket you have defined in
there.

## Creating AWS configuration file

You need to create a configuration file, *aws.vars*, that points the upload
script to the correct S3 bucket. Here's an example:

    S3BUCKET="packer-course.acme.org"

Replace the S3 bucket name with yours and you should be good to go.

## Creating an AMI from the disk image

This process consists of two steps:

1. Upload the disk image to an AWS S3 bucket
1. Convert the disk image from AWS S3 bucket image into an AMI

Both of these steps have been automated with a script, so all you need to do after the AWS build:

    ../shared/aws/prepare/upload-and-import-to-aws.sh <id>

Where \<id\> is the identifier or revision for this particular disk image.

You can query the status of your VM import job with

    aws ec2 describe-import-image-tasks --import-task-ids <import-task-id>

Where \<import-task-id\> is what you got when you ran *upload-and-import-to-aws.sh*.

# Uploading images to Azure

## Installing Powershell Core for Linux

You need Powershell Core to upload Packer-generated images into Azure. Follow
the steps outlined here to install it:

* https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux?view=powershell-7.4

## Install Az Powershell module

Once Powershell core is installed install the Az module

    $ pwsh
    PS> Install-Module -Name Az -Repository PSGallery -Force
    PS> Update-Module -Name Az -Force

## Creating an Azure config file

To upload to Azure you need to create an azure.vars config file in the root of this Git repository.
For example:

    SUBSCRIPTION_ID="<subscription-id>"
    LOCATION="northeurope"
    DISK_SIZE=13
    RESOURCE_GROUP_NAME="acmeimages"
    STORAGE_ACCOUNT_NAME="acmestorage"

## Uploading images to Azure

Upload the provisinioned image to Azure by running this from the Packer project
directory:

    ../shared/azure/prepare/upload_to_azure.sh <id>

Where \<id\> is a suffix that will get added to the image name, for example
"rev1".

# QEMU-img

Convert a qcow2 image to vmdk:

    $ quemu-img convert -f qcow2 -O vmdk <img_path> <new_img_path>
