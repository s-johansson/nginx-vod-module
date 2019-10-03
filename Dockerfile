FROM alpine:3.9 AS base_image

FROM base_image AS build

RUN apk add --no-cache curl build-base openssl openssl-dev zlib-dev linux-headers pcre-dev ffmpeg ffmpeg-dev libxml2-dev
RUN mkdir nginx nginx-vod-module

ENV NGINX_VERSION 1.17.4
ENV VOD_MODULE_VERSION 1.25

RUN curl -sL https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar -C /nginx --strip 1 -xz
# RUN curl -sL https://github.com/kaltura/nginx-vod-module/archive/${VOD_MODULE_VERSION}.tar.gz | tar -C /nginx-vod-module --strip 1 -xz

ADD . /nginx-vod-module

WORKDIR /nginx
RUN ./configure --prefix=/usr/local/nginx \
    --add-module=/nginx-vod-module \
    --with-http_ssl_module \
    --with-file-aio \
    --with-threads \
    --with-cc-opt="-O3"
RUN make
RUN make install
RUN rm -rf /usr/local/nginx/html /usr/local/nginx/conf/*.default

FROM base_image
RUN apk add --no-cache ca-certificates openssl pcre zlib ffmpeg libxml2
COPY --from=build /usr/local/nginx /usr/local/nginx
ADD nginx-vod.conf /usr/local/nginx/conf/nginx.conf
ENTRYPOINT ["/usr/local/nginx/sbin/nginx"]
CMD ["-g", "daemon off;"]
