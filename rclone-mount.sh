#!/bin/bash
# Validate env vars and set up rclone S3 mount

if [[ -z "${CACHE_MAX_SIZE}" ]]; then
		echo "$(date) [warn] VFS max cache size not defined (via CACHE_MAX_SIZE). Using default: 10G"
		export CACHE_MAX_SIZE="10G"
fi  

if [[ -z "${CACHE_REFRESH_TIME}" ]]; then
		echo "$(date) [warn] Cache refresh time not defined (via CACHE_REFRESH TIME). Using default: 30s"
		export CACHE_REFRESH_TIME="30s"
fi  

if [[ -z "${S3BUCKET}" ]]; then
		echo "$(date) [warn] S3 Bucket Name not defined (via S3BUCKET)."
		export S3BUCKET="1"
fi  

echo "Mounting S3 bucket via rclone..."
echo "$(date) [info] S3 Bucket: '${S3BUCKET}'"
echo "$(date) [info] VFS cache maximum size: '${CACHE_MAX_SIZE}'"
echo "$(date) [info] Cache refresh time: '${CACHE_REFRESH_TIME}'"
/usr/bin/rclone --config=/rclone/config/rclone.conf --cache-dir=/rclone/cache mount remote:${S3BUCKET} /mnt/remote \
                --vfs-cache-mode full --vfs-cache-max-size ${CACHE_MAX_SIZE} --dir-cache-time ${CACHE_REFRESH_TIME} \
	       	--vfs-fast-fingerprint --allow-other --allow-non-empty
