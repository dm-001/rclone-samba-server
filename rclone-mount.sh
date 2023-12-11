#!/bin/bash
# Validate env vars and set up rclone S3 mount

if [[ ! -z "${CACHE_MAX}" ]]; then
		echo "$(date) [info] Max cache size: '${CACHE_MAX}'"
	else
		echo "$(date) [warn] Max cache size not defined (via CACHE_MAX). Using default: 10G"
		export CACHE_MAX="10G"
fi  

if [[ ! -z "${S3BUCKET}" ]]; then
		echo "$(date) [info] S3 Bucket: '${S3BUCKET}'"
	else
		echo "$(date) [warn] S3 Bucket Name not defined (via S3BUCKET)."
		export S3BUCKET="1"
fi  

echo "Mounting S3 bucket via rclone..."
/usr/bin/rclone --config=/rclone/config/rclone.conf --cache-dir=/rclone/cache mount remote:${S3BUCKET} /mnt/remote \
                --vfs-cache-mode writes --vfs-cache-max-size ${CACHE_MAX}  --vfs-fast-fingerprint --allow-other --allow-non-empty