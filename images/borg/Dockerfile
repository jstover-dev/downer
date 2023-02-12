FROM alpine:3.17.2

RUN apk add --no-cache 'openssh-client~=9.1' 'borgbackup~=1.2'

USER root
VOLUME /root
VOLUME /archive

COPY entrypoint.sh /
COPY backup.sh /usr/bin/backup
COPY crontab /etc/crontabs/root

ENTRYPOINT ["/entrypoint.sh"]

CMD ["crond", "-f", "-L", "/dev/stdout", "-c", "/etc/crontabs"]
