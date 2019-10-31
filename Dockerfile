FROM alpine:3.10 AS base_image

FROM base_image AS build

ENV NGINX_VERSION 1.17.5
ENV VOD_MODULE_VERSION 1.25
# fix for build lua module to locate luajit.h
ENV C_INCLUDE_PATH /usr/include/luajit-2.1/

ADD . /nginx_vod_module

WORKDIR /nginx
RUN apk add --no-cache \
    build-base \
    curl \
    ffmpeg \
    ffmpeg-dev \
    libxml2-dev \
    linux-headers \
    lua-dev \
    luajit-dev \
    pcre-dev \
    openssl \
    openssl-dev \
    zlib-dev && \

    mkdir /nginx_lua_module && \
    curl -sL https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar -C /nginx --strip 1 -xz && \
    curl -sL https://github.com/openresty/lua-nginx-module/archive/v0.10.15.tar.gz | tar -C /nginx_lua_module --strip 1 -xz && \

    ./configure --prefix=/usr/local/nginx \
    --add-module=/nginx_vod_module \
    --add-module=/nginx_lua_module \
    --with-http_ssl_module \
    --with-file-aio \
    --with-threads \
    --with-cc-opt="-O3" && \

    make && \
    make install && \
    rm -rf /usr/local/nginx/html /usr/local/nginx/conf/*.default

FROM base_image
RUN apk add --no-cache \
    ca-certificates \
    ffmpeg \
    libxml2 \
    lua \
    lua-dev \
    luajit \
    openssl \
    pcre \
    zlib

COPY --from=build /usr/local/nginx /usr/local/nginx
ADD nginx-vod.conf /usr/local/nginx/conf/nginx.conf
ENTRYPOINT ["/usr/local/nginx/sbin/nginx"]
CMD ["-g", "daemon off;"]
