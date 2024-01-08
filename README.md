# RClone S3 Samba Server
This docker image mounts an S3 bucket via [rclone](https://rclone.org) and exposes that mount via SMB.
Forked from https://gitlab.com/encircle360-oss/rclone-samba-server

Configuration is via environment variables, and an rclone.conf remote configuration.

ENVIRONMENT VARIABLES

 * `SHARE` - Define an SMB share. Format is identical to dperson/samba: name; share path; browse; readonly; guest; users; admins; writelist; comment;
 * `TZ` - Set timezone
 * `USER` - Define a user for share access (username;password)
 * `CACHE_MAX_SIZE` - Set maximum size of VFC file cache
 * `CACHE_REFRESH_TIME` - Set the maximum time file and dir info will be cached before checking for changes in s3
 * `S3BUCKET` - Name of, or name and subdirectory of, the S3 Bucket to mount and share

Samba is implemented via [dperson/samba](https://github.com/dperson/samba) so all SMB configuration options from the dperson/samba container will also work for this container.


# Pending changes
1. Remove need for container to run privileged (currently required for FUSE interaction and mount)
2. Extend readme to include rclone config requirements, cache options etc

# Example Usage

Create a rclone.conf file (rclone configuration) that contains the details of the S3 bucket you wish to mount. Put this file in it's own subfolder, and ensure the subfolder is mapped to /rclone/config in the container below.

e.g.
```
[remote]
type = s3
provider = AWS
access_key_id = myAccessKey
secret_access_key = myReallySuperSecretKey
region = ap-southeast-2
acl = private
server_side_encryption = AES256
```


Start the container, ensuring the environment variables have been defined and the rclone.conf folder is mapped to /rclone/config
An example using docker compose is below.


```
version: "3.5"

services:

  s3-samba:
    # Build container direct from github
    build: https://github.com/dm-001/rclone-samba-server.git
    volumes:
      # Ensure rclone.conf is mapped to /rclone/config/rclone.conf
      - "./data/config:/rclone/config"
      # Allow persistence for cache data, just in case there's a crash or similar
      - "./data/cache:/rclone/cache"
    environment:
      # Set timezone
      - "TZ=Australia/Melbourne"
      # Create user for share access
      - "USER=myUser;myPassword"
      # Define a share as per dperson/samba standard
      - "SHARE=remote;/mnt/remote;yes;no;no;myUser;none;;;"
      # Define max cache data size
      - "CACHE_MAX_SIZE=5G"
      # Define directory cache expiry time
      - "CACHE_REFRESH_TIME=1m30s"
      # Define bucket name to mount
      - "S3BUCKET=myS3bucket"
    restart: unless-stopped
    ports:
      - 445:445
      - 139:139/udp
      - 138:138/upd
    devices:
      # Needed to handle s3 mount to local storage
      - "/dev/fuse:/dev/fuse:rwm"
    cap_add:
      - SYS_ADMIN
      - NET_ADMIN
    privileged: true
    security_opt:
      - apparmor:unconfined
```
