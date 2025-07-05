#!/bin/bash


if [ ! -f "/etc/rspamd/rspamd.conf" ]; then
  cp -rnp /rspamd_init/* /etc/rspamd/
fi

if [ ! -f "/etc/rspamd/local.d/milter_headers.conf" ]; then
  cp -rnp /rspamd_init/* /etc/rspamd/
fi

# Check if there is an bind_socket = "*:11334"; configuration, and if not, force copy the file
CHECK_CONF=$(grep 'bind_socket = "*:11334";' /etc/rspamd/rspamd.conf)
if [ -z "${CHECK_CONF}" ]; then
  \cp -arpf /rspamd_init/rspamd.conf /etc/rspamd/rspamd.conf
fi

# Check if there is an services =  configuration, and if not, force copy the file
CHECK_CONF=$(grep "services = " /etc/rspamd/statistic.conf)
if [ -z "${CHECK_CONF}" ]; then
  \cp -arpf /rspamd_init/statistic.conf /etc/rspamd/statistic.conf
fi


chmod 755 /var/lib/rspamd
chown -R _rspamd:_rspamd /var/lib/rspamd

cat <<EOF > /etc/rspamd/local.d/redis.conf
servers = "redis:6379"; # Read servers (unless write_servers are unspecified)
write_servers = "redis:6379"; # Servers to write data
disabled_modules = ["ratelimit"]; # List of modules that should not use redis from this section
timeout = 10s;
db = "0";
password = "${REDISPASS}";
EOF

exec "$@"
