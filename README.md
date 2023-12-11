# RClone S3 Samba Server
This docker image mounts an S3 bucket via [rclone](https://rclone.org) and exposes that mount via SMB.
Forked from https://gitlab.com/encircle360-oss/rclone-samba-server

Configuration is via environment variables, and an rclone.conf remote configuration.

ENVIRONMENT VARIABLES

 * `SHARE` - Define an SMB share. Format is identical to dperson/samba: "<name;/path>[;browse;readonly;guest;users;admins;writelist;comment]"
 * `TZ` - Set timezone
 * `USER` - Define a user for share access (username;password)
 * `CACHE_MAX` - Set max size of VFC cache
 * `S3BUCKET` - Name of, or name and subdirectory of, the S3 Bucket to mount and share

Samba is implemented via [dperson/samba](https://github.com/dperson/samba) so all SMB configuration options from the dperson/samba container will also work for this container.


# Pending changes
1. Remove need for container to run privileged (currently required for FUSE interaction and mount)
2. Extend readme to include rclone config requirements, cache options etc

# Example Usage

```
version: "3.5"

services:

  s3-samba:
    build: https://github.com/dm-001/rclone-samba-server.git
    volumes:
      - "./data/config:/rclone/config"
      - "./data/cache:/rclone/cache"
    environment:
      - "TZ=Australia/Melbourne"
      - "USER=myUser;myPassword"
      - "SHARE=remote;/mnt/remote;yes;no;no;myUser;none;;;"
      - "CACHE_MAX=5G"
      - "S3BUCKET=myS3bucket"
    restart: unless-stopped
    ports:
      - 445:445
      - 139:139
      - 138:138
    devices:
      - "/dev/fuse:/dev/fuse:rwm"
    cap_add:
      - SYS_ADMIN
      - NET_ADMIN
    privileged: true
    security_opt:
      - apparmor:unconfined
```
