FROM nginx:mainline AS BUILD

LABEL mantainer="Adrian Kriel <admin@extremeshok.com>" vendor="eXtremeSHOK.com"

################################################
#### MULTIBUILD: Stage 1 #######################
################################################

ENV OSSL_VERSION 1.1.1

ENV DEBIAN_FRONTEND noninteractive

# ENFORCE en_us UTF8
ENV SHELL=/bin/bash \
  LC_ALL=en_US.UTF-8 \
  LANG=en_US.UTF-8 \
  LANGUAGE=en_US.UTF-8

USER root

RUN echo "**** install packages ****" \
  && apt-get update && apt-get install -o Dpkg::Options::="--force-confmiss" -o Dpkg::Options::="--force-confold" -y \
  autoconf \
  automake \
  autotools-dev \
  build-essential \
  ca-certificates \
  ccache \
  curl \
  dpkg-dev \
  gcc \
  git \
  gnupg \
  gnupg2 \
  google-perftools \
  libbsd-dev \
  libbz2-1.0 \
  libbz2-dev \
  libbz2-ocaml \
  libbz2-ocaml-dev \
  libcurl4-openssl-dev \
  libgd-dev \
  libgd3 \
  libgmp-dev \
  libgoogle-perftools-dev \
  libjansson-dev \
  libjemalloc-dev \
  libjpeg-dev \
  libjpeg62-turbo-dev \
  libpcre3 \
  libpcre3-dev \
  libperl-dev \
  libpng-dev \
  libreadline-dev \
  libssl-dev \
  libtool \
  libwebp-dev \
  libxml2 \
  libxml2-dev \
  libxslt1-dev \
  locales \
  perl \
  python-pip \
  software-properties-common \
  tar \
  unzip \
  uuid-dev \
  wget \
  zlib1g-dev

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
  && locale-gen

RUN  echo "**** Add Nginx Repo ****" \
  && CODENAME=$(grep -Po 'VERSION="[0-9]+ \(\K[^)]+' /etc/os-release) \
  && wget http://nginx.org/keys/nginx_signing.key \
  && apt-key add nginx_signing.key \
  && echo "deb http://nginx.org/packages/mainline/debian/ ${CODENAME} nginx" >> /etc/apt/sources.list \
  && echo "deb-src http://nginx.org/packages/mainline/debian/ ${CODENAME} nginx" >> /etc/apt/sources.list \
  && apt-get update

RUN echo "**** Prepare Nginx ****" \
  && mkdir -p /usr/local/src/nginx && cd /usr/local/src/nginx/ \
  && apt source nginx

RUN echo "*** Nginx Version ****" \
  && NGINX_VERSION=$(nginx -v 2>&1 | nginx -v 2>&1 | cut -d'/' -f2) \
  && echo "Nginx Version: ${NGINX_VERSION}"

RUN echo "**** Add OpenSSL 1.1.1 ****" \
  && cd /usr/local/src \
  && git clone --recursive --depth=1 https://github.com/openssl/openssl.git -b OpenSSL_1_1_1-stable \
  && sed -i 's|--with-ld-opt="$(LDFLAGS)"|--with-ld-opt="$(LDFLAGS)" --with-openssl=/usr/local/src/openssl --with-openssl-opt="enable-ec_nistp_64_gcc_128"|g' /usr/local/src/nginx/nginx-*/debian/rules

RUN echo "**** Add set misc ****" \
  && cd /usr/local/src \
  && git clone --recursive --depth=1 https://github.com/openresty/set-misc-nginx-module.git \
  && sed -i 's|--with-ld-opt="$(LDFLAGS)"|--with-ld-opt="$(LDFLAGS)" --add-module=/usr/local/src/set-misc-nginx-module|g' /usr/local/src/nginx/nginx-*/debian/rules

RUN echo "**** Add vts ****" \
  && cd /usr/local/src \
  && git clone --recursive --depth=1 https://github.com/vozlt/nginx-module-vts.git \
  && sed -i 's|--with-ld-opt="$(LDFLAGS)"|--with-ld-opt="$(LDFLAGS)" --add-module=/usr/local/src/nginx-module-vts|g' /usr/local/src/nginx/nginx-*/debian/rules

RUN echo "**** Add Brotli ****" \
  && cd /usr/local/src \
  && git clone --recursive --depth=1 https://github.com/yverry/ngx_brotli.git \
  && sed -i 's|--with-ld-opt="$(LDFLAGS)"|--with-ld-opt="$(LDFLAGS)" --add-module=/usr/local/src/ngx_brotli|g' /usr/local/src/nginx/nginx-*/debian/rules

RUN echo "**** Add More Headers ****" \
  && cd /usr/local/src \
  && git clone --recursive --depth=1 https://github.com/openresty/headers-more-nginx-module.git \
  && sed -i 's|--with-ld-opt="$(LDFLAGS)"|--with-ld-opt="$(LDFLAGS)" --add-module=/usr/local/src/headers-more-nginx-module|g' /usr/local/src/nginx/nginx-*/debian/rules

RUN echo "**** Add Upload Progress ****" \
  && cd /usr/local/src \
  && git clone --recursive --depth=1 https://github.com/masterzen/nginx-upload-progress-module.git \
  && sed -i 's|--with-ld-opt="$(LDFLAGS)"|--with-ld-opt="$(LDFLAGS)" --add-module=/usr/local/src/nginx-upload-progress-module|g' /usr/local/src/nginx/nginx-*/debian/rules

RUN echo "**** Add Cache Purge ****" \
  && cd /usr/local/src \
  && git clone --recursive --depth=1 https://github.com/nginx-modules/ngx_cache_purge.git \
  && sed -i 's|--with-ld-opt="$(LDFLAGS)"|--with-ld-opt="$(LDFLAGS)" --add-module=/usr/local/src/ngx_cache_purge|g' /usr/local/src/nginx/nginx-*/debian/rules

RUN echo "**** Add Geoip2 ****" \
  && cd /usr/local/src \
  && git clone --recursive --depth=1 https://github.com/leev/ngx_http_geoip2_module.git \
  && sed -i 's|--with-ld-opt="$(LDFLAGS)"|--with-ld-opt="$(LDFLAGS)" --add-module=/usr/local/src/ngx_http_geoip2_module|g' /usr/local/src/nginx/nginx-*/debian/rules

RUN echo "**** Add Redis2 ****" \
  && cd /usr/local/src \
  && git clone --recursive --depth=1 https://github.com/openresty/redis2-nginx-module.git \
  && sed -i 's|--with-ld-opt="$(LDFLAGS)"|--with-ld-opt="$(LDFLAGS)" --add-module=/usr/local/src/redis2-nginx-module|g' /usr/local/src/nginx/nginx-*/debian/rules

RUN echo "**** Add Webdav ****" \
  && cd /usr/local/src \
  && git clone --recursive --depth=1 https://github.com/arut/nginx-dav-ext-module.git \
  && sed -i 's|--with-ld-opt="$(LDFLAGS)"|--with-ld-opt="$(LDFLAGS)" --with-http_dav_module --add-module=/usr/local/src/nginx-dav-ext-module|g' /usr/local/src/nginx/nginx-*/debian/rules

RUN echo "**** Memc  (memcached) ****" \
  && cd /usr/local/src \
  && git clone --recursive --depth=1 https://github.com/openresty/memc-nginx-module.git \
  && sed -i 's|--with-ld-opt="$(LDFLAGS)"|--with-ld-opt="$(LDFLAGS)" --add-module=/usr/local/src/memc-nginx-module|g' /usr/local/src/nginx/nginx-*/debian/rules

RUN echo "**** Srcache ****" \
  && cd /usr/local/src \
  && git clone --recursive --depth=1 https://github.com/openresty/srcache-nginx-module.git \
  && sed -i 's|--with-ld-opt="$(LDFLAGS)"|--with-ld-opt="$(LDFLAGS)" --add-module=/usr/local/src/srcache-nginx-module|g' /usr/local/src/nginx/nginx-*/debian/rules

RUN echo "**** echo ****" \
  && cd /usr/local/src \
  && git clone --recursive --depth=1 https://github.com/openresty/echo-nginx-module.git \
  && sed -i 's|--with-ld-opt="$(LDFLAGS)"|--with-ld-opt="$(LDFLAGS)" --add-module=/usr/local/src/echo-nginx-module|g' /usr/local/src/nginx/nginx-*/debian/rules

RUN echo "**** http_substitutions_filter ****" \
  && cd /usr/local/src \
  && git clone --recursive --depth=1 https://github.com/yaoweibin/ngx_http_substitutions_filter_module.git \
  && sed -i 's|--with-ld-opt="$(LDFLAGS)"|--with-ld-opt="$(LDFLAGS)" --add-module=/usr/local/src/ngx_http_substitutions_filter_module|g' /usr/local/src/nginx/nginx-*/debian/rules

RUN echo "**** http concat ****" \
  && cd /usr/local/src \
  && git clone --recursive --depth=1 https://github.com/alibaba/nginx-http-concat.git \
  && sed -i 's|--with-ld-opt="$(LDFLAGS)"|--with-ld-opt="$(LDFLAGS)" --add-module=/usr/local/src/nginx-http-concat|g' /usr/local/src/nginx/nginx-*/debian/rules

RUN echo "**** Add pagespeed ****" \
  && pip install lastversion \
  && THISVERSION="$(lastversion apache/incubator-pagespeed-ngx)" \
  && curl --silent -o /tmp/ngx-pagespeed.tar.gz -L "https://github.com/apache/incubator-pagespeed-ngx/archive/v${THISVERSION}-stable.tar.gz" \
  && mkdir -p /usr/local/src/ngx-pagespeed \
  && tar xfz /tmp/ngx-pagespeed.tar.gz -C /usr/local/src/ngx-pagespeed \
  && rm -f /tmp/ngx-pagespeed.tar.gz \
  && mv -f /usr/local/src/ngx-pagespeed/*/* /usr/local/src/ngx-pagespeed \
  && curl --silent -o /tmp/psol.tar.gz -L "https://dl.google.com/dl/page-speed/psol/${THISVERSION}-x64.tar.gz" \
  && tar xfz /tmp/psol.tar.gz -C /usr/local/src/ngx-pagespeed \
  && rm -f /tmp/psol.tar.gz \
  && sed -i 's|--with-ld-opt="$(LDFLAGS)"|--with-ld-opt="$(LDFLAGS)" --add-module=/usr/local/src/ngx-pagespeed|g' /usr/local/src/nginx/nginx-*/debian/rules

# this needs to be last
RUN echo "**** Add Nginx Development Kit ****" \
  && cd /usr/local/src \
  && git clone --recursive --depth=1 https://github.com/simplresty/ngx_devel_kit.git \
  && sed -i 's|--with-ld-opt="$(LDFLAGS)"|--with-ld-opt="$(LDFLAGS)" --add-module=/usr/local/src/ngx_devel_kit|g' /usr/local/src/nginx/nginx-*/debian/rules

RUN echo "*** Patch Nginx Build Config ***" \
  && NGINX_VERSION=$(nginx -v 2>&1 | nginx -v 2>&1 | cut -d'/' -f2) \
  && sed -i 's|CFLAGS="$CFLAGS -Werror"|#CFLAGS="$CFLAGS -Werror"|g' /usr/local/src/nginx/nginx-*/auto/cc/gcc \
  && sed -i 's|dh_shlibdeps -a|dh_shlibdeps -a --dpkg-shlibdeps-params=--ignore-missing-info|g' /usr/local/src/nginx/nginx-*/debian/rules \
#  && sed -i 's|--with-ld-opt="$(LDFLAGS)"|--with-ld-opt="$(LDFLAGS)" --with-http_image_filter_module|g' /usr/local/src/nginx/nginx-*/debian/rules \
  && sed -i 's|--with-ld-opt="$(LDFLAGS)"|--with-ld-opt="$(LDFLAGS)" --with-http_xslt_module|g' /usr/local/src/nginx/nginx-*/debian/rules

COPY ./patches /patches

# RUN echo "*** Patch Nginx (Dynamic TLS Record Resizing)" \
#   && cd /usr/local/src/nginx/nginx-*/ \
#   &&  patch -p1 < /patches/nginx_dynamic_tls_records_1015008.patch
#
# RUN echo "*** Patch Nginx (HTTP2 Server Push)" \
#   && cd /usr/local/src/nginx/nginx-*/ \
#   &&  patch -p1 < /patches/nginx_1.11.12_http2_server_push.patch
#
# RUN echo "*** Patch Nginx (SPDY)" \
#   && cd /usr/local/src/nginx/nginx-*/ \
#   &&  patch -p1 < /patches/nginx_1.13.0_http2_spdy.patch
#
# RUN echo "*** Patch Nginx (OpenSSL Renegotiation Fix)" \
#   && cd /usr/local/src/nginx/nginx-*/ \
#   &&  patch -p1 < /patches/nginx_openssl-1.1.x_renegotiation_fix.patch
#
# RUN echo "*** Patch Nginx (Fix Max Protocol Version)" \
#   && cd /usr/local/src/nginx/nginx-*/ \
#   &&  patch -p1 < /patches/nginx-1.15.5-fix-max-protocol-version.patch
#
# RUN echo "*** Patch Nginx (HTTP2 HPACK)" \
#   && cd /usr/local/src/nginx/nginx-*/ \
#   &&  patch -p1 < /patches/nginx-1.15.8_http2-hpack.patch \
#   && sed -i 's|--with-ld-opt="$(LDFLAGS)"|--with-ld-opt="$(LDFLAGS)" --with-http_v2_hpack_enc|g' /usr/local/src/nginx/nginx-*/debian/rules

RUN echo "*** Patch Nginx (SPDY, HTTP2 HPACK, Dynamic TLS Records)" \
  && cd /usr/local/src/nginx/nginx-*/ \
  && patch -p1 < /patches/kn007_nginx.patch \
  && sed -i 's|--with-ld-opt="$(LDFLAGS)"|--with-ld-opt="$(LDFLAGS)" --with-http_v2_hpack_enc|g' /usr/local/src/nginx/nginx-${NGINX_VERSION}/debian/rules

RUN echo "*** Patch Nginx (Prioritize chacha)" \
  && cd /usr/local/src/nginx/nginx-*/ \
  &&  patch -p1 < /patches/nginx-1.15.4-reprioritize-chacha-openssl-1.1.1.patch

RUN echo "*** Add libbrotli ****" \
  && cd /usr/local/src \
  && git clone --recursive --depth=1 https://github.com/bagder/libbrotli.git \
  && cd libbrotli \
  && ./autogen.sh \
  && ./configure \
  && make -j $(nproc) \
  && make install \
  && ldconfig

RUN echo "*** Add libmaxminddb ****" \
  && cd /usr/local/src \
  && git clone --recursive --depth=1 https://github.com/maxmind/libmaxminddb.git \
  && cd libmaxminddb \
  && ./bootstrap \
  && ./configure \
  && make -j $(nproc) \
  && make install \
  && ldconfig

RUN echo "*** Add libgd ****" \
  && cd /usr/local/src \
  && git clone --recursive --depth=1 https://github.com/libgd/libgd.git \
  && cd libmaxminddb \
  && ./bootstrap \
  && ./configure \
  && make -j $(nproc) \
  && make install \
  && ldconfig

RUN echo "*** Add zlib-cf ****" \
  && cd /usr/local/src \
  && git clone --recursive --depth=1 https://github.com/cloudflare/zlib.git -b gcc.amd64 /usr/local/src/zlib-cf \
  && cd zlib-cf \
  && ./configure \
  && make -j $(nproc) \
  && make install \
  && ldconfig \
  && sed -i 's|--with-ld-opt="$(LDFLAGS)"|--with-ld-opt="$(LDFLAGS)" --with-zlib=/usr/local/src/zlib-cf|g' /usr/local/src/nginx/nginx-*/debian/rules

RUN echo "*** Add PCRE-Jit ***" \
  && PCRE_VER=$(curl -sL https://ftp.pcre.org/pub/pcre/ | grep -E -o 'pcre\-[0-9.]+\.tar[.a-z]*gz' | awk -F "pcre-" '/.tar.gz$/ {print $2}' | sed -e 's|.tar.gz||g' | tail -n 1 2>&1) \
  && curl --silent -o /tmp/pcre.tar.gz -L "https://ftp.pcre.org/pub/pcre/pcre-${PCRE_VER}.tar.gz" \
  && mkdir -p /usr/local/src/pcre \
  && tar xfz /tmp/pcre.tar.gz -C /usr/local/src/pcre \
  && rm -f /tmp/pcre.tar.gz \
  && mv -f /usr/local/src/pcre/*/* /usr/local/src/pcre \
  && cd /usr/local/src/pcre \
  && ./configure --prefix=/usr/local/ --enable-utf8 --enable-unicode-properties --enable-pcre16 --enable-pcre32 --enable-pcregrep-libz --enable-pcregrep-libbz2 --enable-pcretest-libreadline --enable-jit \
  && make -j "$(nproc)" \
  && make install \
  && ldconfig \
  && sed -i 's|--with-ld-opt="$(LDFLAGS)"|--with-ld-opt="$(LDFLAGS)" --with-pcre-jit --with-pcre=/usr/local/src/pcre|g' /usr/local/src/nginx/nginx-*/debian/rules

RUN echo "*** Build Nginx ***" \
  && cd /usr/local/src/nginx/nginx-*/ \
  && cat debian/rules \
  && cat auto/lib/libgd/conf \
  && apt-get -y purge nginx* \
  && rm -rf /usr/lib/nginx/modules/* \
  && apt build-dep nginx -y  \
  && dpkg-buildpackage -b \
  && cd /usr/local/src/nginx \
  && dpkg -i nginx*.deb \
  &&  cp -f $(echo "/usr/local/src/nginx/nginx_*.deb") /usr/local/src/nginx.deb

################################################
#### MULTIBUILD: Stage 2 #######################
################################################

FROM nginx:mainline AS BASE

ENV DEBIAN_FRONTEND noninteractive

# ENFORCE en_us UTF8
ENV SHELL=/bin/bash \
  LC_ALL=en_US.UTF-8 \
  LANG=en_US.UTF-8 \
  LANGUAGE=en_US.UTF-8

USER root

RUN echo "**** Set local to en_US.UTF8 ****" \
  && apt-get update && apt-get install -o Dpkg::Options::="--force-confmiss" -o Dpkg::Options::="--force-confold" -y locales \
  && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
  && locale-gen

RUN echo "*** remove current nginx ***" \
  && apt-get -y purge nginx* \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /usr/local/lib/* \
  && rm -rf /usr/lib/nginx/modules/*

COPY --from=BUILD /usr/local/lib/libbrotlidec.so /usr/local/lib/libbrotlidec.so
COPY --from=BUILD /usr/local/lib/libbrotlienc.so /usr/local/lib/libbrotlienc.so
COPY --from=BUILD /usr/local/lib/libmaxminddb.so /usr/local/lib/libmaxminddb.so
COPY --from=BUILD /usr/local/lib/libz.so /usr/local/lib/libz.so
COPY --from=BUILD /usr/local/lib/libpcre.so /usr/local/lib/libpcre.so
COPY --from=BUILD /usr/local/lib/libpcre16.so /usr/local/lib/libpcre16.so
COPY --from=BUILD /usr/local/lib/libpcre32.so /usr/local/lib/libpcre32.so
COPY --from=BUILD /usr/local/lib/libpcrecpp.so /usr/local/lib/libpcrecpp.so
COPY --from=BUILD /usr/local/lib/libpcreposix.so /usr/local/lib/libpcreposix.so
RUN ldconfig

COPY --from=BUILD /usr/local/src/nginx.deb /tmp/nginx.deb

RUN echo "*** install nginx ***" \
  && dpkg -i /tmp/nginx.deb \
  && rm -f /tmp/nginx.deb

RUN echo "*** house keeping ***" \
  && apt-get -y autoremove \
  && apt-get -y autoclean \
  && rm -rf /tmp/* \
  && rm -rf /var/lib/apt/lists/*

RUN echo "**** configure ****" \
  && mkdir -p /var/cache/nginx \
  && mkdir -p /var/cache/pagespeed \
  && mkdir -p /var/lib/nginx \
  && mkdir -p /var/run/nginx-cache \
  && mkdir -p /var/www/html

# set proper permissions
RUN echo "*** set permissions ***" \
  && chown -R www-data:root /var/cache/nginx /var/cache/pagespeed /var/lib/nginx /var/run/nginx-cache /var/www/html

WORKDIR /var/www/html

EXPOSE 80

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]
