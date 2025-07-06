#!/bin/sh
set -e

# Substitute environment variables in the nginx config template
envsubst < /usr/local/openresty/nginx/conf/nginx.conf > /usr/local/openresty/nginx/conf/nginx.conf.tmp
mv /usr/local/openresty/nginx/conf/nginx.conf.tmp /usr/local/openresty/nginx/conf/nginx.conf

# Test nginx configuration
/usr/local/openresty/bin/openresty -t

# Start OpenResty with daemon off
exec /usr/local/openresty/bin/openresty -g 'daemon off;'