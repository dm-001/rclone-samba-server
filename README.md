# RClone S3 Samba Server
This docker image mounts an S3 bucket via [rclone](https://rclone.org) and exposes that mount via SMB.

# Pending changes
1. Remove need for container to run privileged (currently required for FUSE interaction and mount)
2. 

# Example Usage

```
version: "3.5"

services:

  s3-samba:
    build: https://github.com/mycompany/example.git
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