FROM dperson/samba:latest
LABEL maintainer="dm-001" \
      version=1.0 \
      description="rclone s3 samba server"

# Forked from https://gitlab.com/encircle360-oss/rclone-samba-server
# rclone version updated to latest stable
# customisations made to allow definition of cache settings and target s3 bucket via env vars

# Add s3 mount dependencies to core samba container image (incl. updated fuse package and conf)
RUN apk --no-cache --no-progress upgrade && \
    apk --no-cache --no-progress add unzip supervisor fuse3 && \
    echo "user_allow_other" >> /etc/fuse.conf && \
    ln -s /usr/bin/fusermount3 /usr/bin/fusermount && \
    wget https://downloads.rclone.org/rclone-current-linux-amd64.zip && \
    unzip rclone*.zip && cd rclone-v* && cp rclone /usr/bin/ && \
    chown root:root /usr/bin/rclone && chmod 755 /usr/bin/rclone && rm -R /rclone-v* && \
    mkdir -p /mnt/remote
COPY supervisord.conf /etc/supervisord.conf
COPY rclone-mount.sh /rclone-mount.sh
RUN  chmod +x /rclone-mount.sh
VOLUME ["/rclone/config", "/rclone/cache"]

# important because otherwise there are problems with write/move access to the rclone mounts
ENV GLOBAL="vfs objects ="
ENV GROUPID=0
ENV USERID=0
ENV PERMISSIONS=true
ENV RECYCLE=false

# to change in production environments, just some defaults
ENV USER="demoUser;changeme"
ENV SHARE="remote;/mnt/remote;yes;no;no;demoUser;none;;;"

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
