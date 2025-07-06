FROM openresty/openresty:1.21.4.1-alpine

RUN apk add --no-cache gettext

# Remove default config if needed
RUN rm -f /etc/nginx/conf.d/default.conf

# Copy entrypoint script
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

# Copy nginx config to OpenResty default location
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]