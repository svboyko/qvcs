#!/bin/sh
set -eu

# 1) SSH host keys (persist them by mounting /etc/ssh if you want stable fingerprints)
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
  ssh-keygen -A
fi

# 2) Install git SSH keys (recommended: mount authorized_keys from the host)
# Expected path: /var/opt/git/keys/authorized_keys
if [ -f /var/opt/git/keys/authorized_keys ]; then
  cp /var/opt/git/keys/authorized_keys /home/git/.ssh/authorized_keys
  chown git:git /home/git/.ssh/authorized_keys
  chmod 600 /home/git/.ssh/authorized_keys
fi

# 3) Basic sshd config hardening for a git-only account
# (keeps image simple: edit inline each start)
# Add 
# LogLevel VERBOSE
# for debug
cat > /etc/ssh/sshd_config <<'EOF'
Port 22
Protocol 2
PasswordAuthentication no
KbdInteractiveAuthentication no
ChallengeResponseAuthentication no
PermitRootLogin no
PermitTTY no
PrintMotd no
PrintLastLog no
X11Forwarding no
AllowTcpForwarding no
PubkeyAuthentication yes
AuthorizedKeysFile /home/git/.ssh/authorized_keys
AllowUsers git
Subsystem sftp internal-sftp
EOF

# Start sshd (daemonizes by default on Alpine when not using -D)
# Add -D -e for debug/log
/usr/sbin/sshd

# 4) Start svnserve in foreground (this is the main container process)
exec /usr/bin/svnserve --daemon --foreground --root /var/opt/svn
