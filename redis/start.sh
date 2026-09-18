#!/bin/sh
set -eu
mkdir -p /var/lib/redis/data
chown -R redis:redis /var/lib/redis
exec redis-server --dir /var/lib/redis/data --appendonly yes --maxmemory-policy allkeys-lru
