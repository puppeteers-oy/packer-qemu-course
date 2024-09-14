#!/bin/sh
#
# Copy disk image to AWS S3 and import it into AWS S3
#
set -e

. ../aws.vars || (echo "ERROR: aws.vars not found from Git repository root!"; exit 1)

if [ "${1}" = "" ]; then
    echo "ERROR: must define disk image ID as the first parameter!"
    exit 1
fi

IMAGE_ID=$1
CWD=$(pwd)
BASENAME=$(basename $CWD)
RAW_IMAGE="${BASENAME}.raw"
S3_IMAGE="${BASENAME}-${IMAGE_ID}.raw"

# Copy the image to S3 if it not present already
aws s3 ls s3://$S3BUCKET/$S3_IMAGE || aws s3 cp build/aws/${RAW_IMAGE} s3://$S3BUCKET/$S3_IMAGE

CONTAINERS_JSON=$(mktemp)

cat ../shared/aws/prepare/containers.json |\
	sed s/"xxS3BUCKETxx"/"${S3BUCKET}"/g |\
	sed s/"xxS3KEYxx"/"${S3_IMAGE}"/g > $CONTAINERS_JSON

aws ec2 import-image --description "${BASENAME}-${IMAGE_ID}" --no-paginate --disk-containers file://${CONTAINERS_JSON}

rm "${CONTAINERS_JSON}"
