#!/bin/sh

set -eo pipefail

if [ ! -d /var/cache/squid ]; then
  mkdir -p /var/cache/squid
fi

if [ ! -d /var/log/squid ]; then
  mkdir -p /var/log/squid
fi

chown -R squid:squid /var/cache/squid
chown -R squid:squid /var/log/squid

rm -rf /var/run/squid /var/run/squid.pid

if [ ! -d /var/cache/squid/00 ]; then
  echo "Initializing cache..."
  /usr/sbin/squid -N -f /etc/squid/squid.conf -z
fi

exec "$@"
