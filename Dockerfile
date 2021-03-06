FROM alpine:3.15.4 AS base_image

FROM base_image AS build

ENV NGINX_VERSION 1.21.2
ENV VOD_MODULE_VERSION 1.29
ENV LUA_NGINX_MODULE_VERSION 0.10.20
ENV NGX_DEVEL_KIT_VERSION 0.3.1
ENV AKAMAI_TOKEN_VERSION 1.1
ENV NGINX_SECURE_TOKEN_VERSION 1.4
# fix for build lua module to locate luajit.h
# ENV C_INCLUDE_PATH /usr/include/luajit-2.1/
ENV LUAJIT_INC /usr/include/luajit-2.1/
ENV LUAJIT_LIB /usr/lib

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
    \
    mkdir /nginx_lua_module /nginx_devel_kit /nginx-akamai-token-validate-module /nginx-secure-token-module && \
    curl -sL https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar -C /nginx --strip 1 -xz && \
    curl -sL https://github.com/openresty/lua-nginx-module/archive/v${LUA_NGINX_MODULE_VERSION}.tar.gz | tar -C /nginx_lua_module --strip 1 -xz && \
    curl -sL https://github.com/simplresty/ngx_devel_kit/archive/v${NGX_DEVEL_KIT_VERSION}.tar.gz | tar -C /nginx_devel_kit --strip 1 -xz && \
    curl -sL https://github.com/kaltura/nginx-akamai-token-validate-module/archive/${AKAMAI_TOKEN_VERSION}.tar.gz | tar -C /nginx-akamai-token-validate-module --strip 1 -xz &&\
    curl -sL https://github.com/kaltura/nginx-secure-token-module/archive/${NGINX_SECURE_TOKEN_VERSION}.tar.gz | tar -C /nginx-secure-token-module --strip 1 -xz &&\
    \
    ./configure --prefix=/usr/local/nginx \
    --add-module=/nginx_vod_module \
    --add-module=/nginx_lua_module \
    --add-module=/nginx_devel_kit \
    --add-module=/nginx-akamai-token-validate-module \
    --add-module=/nginx-secure-token-module \
    --with-http_ssl_module \
    --with-file-aio \
    --with-threads \
    --with-cc-opt="-O3" && \
    \
    make && \
    make install && \
    rm -rf /usr/local/nginx/html /usr/local/nginx/conf/*.default

FROM base_image
RUN apk add --no-cache \
    build-base \
    ca-certificates \
    ffmpeg \
    curl \
    libxml2 \
    lua \
    lua-dev \
    luajit \
    openssl \
    pcre \
    zlib && \
    \
    mkdir /lua_resty_core && \
    curl -sL https://github.com/openresty/lua-resty-core/archive/v0.1.22.tar.gz | tar -C /lua_resty_core --strip 1 -xz && \
    cd /lua_resty_core && \
    make install

COPY --from=build /usr/local/nginx /usr/local/nginx
# default nginx config, could be overwriten with specific bind mount
ADD nginx_conf/nginx-vod.conf /usr/local/nginx/conf/nginx.conf
ENTRYPOINT ["/usr/local/nginx/sbin/nginx"]
CMD ["-g", "daemon off;"]
