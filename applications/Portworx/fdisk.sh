# #!/usr/bin/env bash

set -euo pipefail

DEVICE=$1

# Validate input
if [ ! -b "$DEVICE" ]; then
  echo "Error: $DEVICE is not a valid block device"
  exit 1
fi

echo "Wiping existing partition table on $DEVICE..."
sgdisk --zap-all "$DEVICE"

echo "Creating partitions on $DEVICE..."

# Create 64GiB partition (Partition 1)
sgdisk -n1:0:+64G -t1:8300 -c1:"pxdata64" "$DEVICE"

# Create remaining space partition (Partition 2)
sgdisk -n2:0:0    -t2:8300 -c2:"pxdataRest" "$DEVICE"



echo "Partition layout for $DEVICE:"
lsblk "$DEVICE"
