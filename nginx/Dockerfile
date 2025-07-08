FROM openresty/openresty:1.21.4.1-alpine-fat

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/' /etc/apk/repositories \
 && apk update && apk add --no-cache curl git unzip

# Manually install lua-resty-http
RUN wget https://github.com/ledgetech/lua-resty-http/archive/v0.16.tar.gz && \
    tar -xzf v0.16.tar.gz && \
    cp -r lua-resty-http-0.16/lib/resty /usr/local/openresty/lualib/ && \
    rm -rf v0.16.tar.gz lua-resty-http-0.16

COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/docker-entrypoint.sh"]
