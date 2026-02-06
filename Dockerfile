# QVCS project

FROM garethflowers/svn-server:latest

# Add only what we need for Git over SSH
RUN apk add --no-cache git openssh shadow && \
    adduser -D -h /home/git -s /usr/bin/git-shell git && \
    usermod -p '*' git && \
    mkdir -p /var/opt/git /home/git/.ssh && \
    chown -R git:git /var/opt/git /home/git && \
    chmod 700 /home/git/.ssh

# Our entrypoint starts sshd (daemon) + svnserve (foreground)
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22 3690
VOLUME ["/var/opt/svn", "/var/opt/git"]
ENTRYPOINT ["/entrypoint.sh"]
