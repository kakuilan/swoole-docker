FROM centos:centos7

MAINTAINER kakuilan kakuilan@163.com

# dir and version
ENV SRC_DIR /usr/local/src
ENV WWW_DIR /var/www
ENV WWW_USER www
ENV MEMORY_LIMIT 512

ENV RE2C_VER 1.1.1
ENV LIBICONV_VER 1.15
ENV HIREDIS_VER 0.14.0

ENV PHP_VER 7.2.13
ENV PHP_DIR /usr/local/php/${PHP_VER}
ENV PHP_LOG_DIR /var/log/php
ENV PHP_ETC_DIR ${PHP_DIR}/etc
ENV PHP_INI_DIR ${PHP_ETC_DIR}/php.d

ENV SWOOLE_VER 4.2.9
ENV PHPDS_VER 1.2.7
ENV PHPMCRYPT_VER 1.0.1
ENV PHPREDIS_VER 4.2.0
ENV PHPIMAGICK_VER 3.4.3
ENV PHPXHPROF_VER 2.0.5
ENV PHPINOTIFY_VER 2.0.0

# update yum repo
RUN yum install -y epel-release
RUN yum repolist

# tools
RUN yum -y install \
	wget \
	gcc \
	gcc-c++ \
	make \
	cmake \
	autoconf \
	ImageMagick-devel \
	bison-devel \
	bzip2-devel \
	expat-devel \
	freetype-devel \
	gd-devel \
	gmp-devel \
	libargon2 \
	libargon2-devel \
	libXpm \
	libXpm-devel \
	libcurl \
	libcurl-devel \
	libicu \
	libicu-devel \
	libidn \
	libidn-devel \
	libjpeg \
	libjpeg-devel \
	libjpeg-turbo \
	libjpeg-turbo-devel \
	libmcrypt \
	libmcrypt-devel \
	libnghttp2 \
	libnghttp2-devel \
	libpng \
	libpng-devel \
	libsodium \
	libsodium-devel \
	libtidy \
	libtidy-devel \
	libwebp \
	libwebp-devel \
	libxml2 \
	libxml2-devel \
	libxslt \
	libxslt-devel \
	mhash \
	mhash-devel \
	net-snmp-devel \
	openssl-devel \
	pcre \
	pcre-devel \
	readline-devel \
	sqlite-devel \
	unixODBC-devel \
	zlib-devel \
  && yum clean all

# copy files
RUN mkdir -p ${SRC_DIR} ${PHP_LOG_DIR}
COPY conf pack ${SRC_DIR}/
RUN chmod +rw -R ${PHP_LOG_DIR}

# go src dir
WORKDIR ${SRC_DIR}
RUN pushd ${SRC_DIR}
RUN ls ${SRC_DIR}

# install re2c
# wget https://github.com/skvadrik/re2c/releases/download/${RE2C_VER}/re2c-${RE2C_VER}.tar.gz -O re2c-${RE2C_VER}.tar.gz
RUN tar xzf re2c-${RE2C_VER}.tar.gz \
  && pushd re2c-${RE2C_VER} \
  && ./configure \
  && make clean \
  && make && make install \
  && popd \
  && rm -rf re2c-${RE2C_VER}

# install hiredis
# wget https://github.com/redis/hiredis/archive/v${HIREDIS_VER}.tar.gz -O hiredis-${HIREDIS_VER}.tar.gz
RUN tar xzf hiredis-${HIREDIS_VER}.tar.gz \
  && pushd hiredis-${HIREDIS_VER} \
  && make clean \
  && make -j && make install \
  && popd \
  && rm -rf hiredis-${HIREDIS_VER}

# install libiconv
# wget http://www.itkb.ro/userfiles/file/libiconv-glibc-2.16.patch.gz
# wget https://ftp.gnu.org/pub/gnu/libiconv/libiconv-${LIBICONV_VER}.tar.gz
RUN tar xzf libiconv-${LIBICONV_VER}.tar.gz \
  && pushd libiconv-${LIBICONV_VER} \
  && ./configure --prefix=/usr/local \
  && make clean \
  && make && make install \
  && popd \
  && rm -rf libiconv-${LIBICONV_VER}

# ldconf libs
RUN echo "include /etc/ld.so.conf.d/*.conf" > /etc/ld.so.conf \
  && echo '/usr/local/lib' > /etc/ld.so.conf \
  && ldconfig -f /etc/ld.so.conf
RUN ldconfig -p

# add user
RUN useradd -M -s /sbin/nologin ${WWW_USER}

# install php
# wget http://hk1.php.net/get/php-${PHP_VER}.tar.gz/from/this/mirror -O php-${PHP_VER}.tar.gz
RUN tar xzf php-${PHP_VER}.tar.gz \
  && pushd php-${PHP_VER} \
  && ./buildconf --force\
  && ./configure \
	--prefix=${PHP_DIR} \
	--with-config-file-path=${PHP_ETC_DIR} \
	--with-config-file-scan-dir=${PHP_INI_DIR} \
	--with-fpm-group=${WWW_USER} \
	--with-fpm-user=${WWW_USER} \
	--disable-debug \
	--disable-rpath \
	--enable-bcmath \
	--enable-calendar \
	--enable-exif \
	--enable-fileinfo \
	--enable-fpm \
	--enable-ftp \
	--enable-inline-optimization \
	--enable-intl \
	--enable-mbregex \
	--enable-mbstring \
	--enable-mysqlnd \
	--enable-opcache \
	--enable-pcntl \
	--enable-session \
	--enable-shared \
	--enable-shmop \
	--enable-soap \
	--enable-sockets \
	--enable-sysvmsg \
	--enable-sysvsem \
	--enable-sysvshm \
	--enable-wddx \
	--enable-xml \
	--enable-zip \
	--with-bz2 \
	--with-curl \
	--with-freetype-dir \
	--with-gd \
	--with-gdbm \
	--with-gettext \
	--with-gmp \
	--with-iconv \
	--with-iconv-dir=/usr/local \
	--with-jpeg-dir \
	--with-libxml-dir=/usr \
	--with-mhash \
	--with-mysqli=mysqlnd \
	--with-openssl \
	--with-password-argon2 \
	--with-pdo-mysql=mysqlnd \
	--with-png-dir \
	--with-readline \
	--with-snmp \
	--with-sodium \
	--with-tidy \
	--with-unixODBC=/usr \
	--with-pdo-odbc=unixODBC,/usr \
	--with-webp-dir \
	--with-xmlrpc \
	--with-xpm-dir \
	--with-xsl \
	--with-zlib \
	--without-pear \
  && make clean \
  && make ZEND_EXTRA_LIBS='-liconv' \
  && make install

# php path and conf
RUN sed -i "s@^export PATH=\(.*\)@export PATH=${PHP_DIR}/bin:\1@" /etc/profile
RUN . /etc/profile
RUN mkdir -p ${PHP_DIR}/etc/php.d
RUN /bin/cp ${SRC_DIR}/php-${PHP_VER}/php.ini-production ${PHP_DIR}/etc/php.ini

# modify php.ini
RUN sed -i "s@^memory_limit.*@memory_limit = ${MEMORY_LIMIT}M@" ${PHP_DIR}/etc/php.ini
RUN sed -i 's@^output_buffering =@output_buffering = On\noutput_buffering =@' ${PHP_DIR}/etc/php.ini
RUN sed -i 's@^;cgi.fix_pathinfo.*@cgi.fix_pathinfo=0@' ${PHP_DIR}/etc/php.ini
RUN sed -i 's@^short_open_tag = Off@short_open_tag = On@' ${PHP_DIR}/etc/php.ini
RUN sed -i 's@^expose_php = On@expose_php = Off@' ${PHP_DIR}/etc/php.ini
RUN sed -i 's@^request_order.*@request_order = "CGP"@' ${PHP_DIR}/etc/php.ini
RUN sed -i 's@^;date.timezone.*@date.timezone = Asia/Shanghai@' ${PHP_DIR}/etc/php.ini
RUN sed -i 's@^post_max_size.*@post_max_size = 32M@' ${PHP_DIR}/etc/php.ini
RUN sed -i 's@^upload_max_filesize.*@upload_max_filesize = 32M@' ${PHP_DIR}/etc/php.ini
RUN sed -i 's@^max_execution_time.*@max_execution_time = 120@' ${PHP_DIR}/etc/php.ini
RUN sed -i 's@^;realpath_cache_size.*@realpath_cache_size = 2M@' ${PHP_DIR}/etc/php.ini
RUN sed -i 's@^disable_functions.*@disable_functions = system,chroot,chgrp,chown,shell_exec,ini_alter,ini_restore,dl,readlink,symlink,popepassthru,stream_socket_server@' ${PHP_DIR}/etc/php.ini
RUN sed -i 's@^;sendmail_path.*@sendmail_path = /usr/sbin/sendmail -t -i@' ${PHP_DIR}/etc/php.ini
RUN sed -i "s@^;curl.cainfo.*@curl.cainfo = ${OPENSSL_DIR}/cert.pem@" ${PHP_DIR}/etc/php.ini
RUN sed -i "s@^;openssl.cafile.*@openssl.cafile = ${OPENSSL_DIR}/cert.pem@" ${PHP_DIR}/etc/php.ini
RUN sed -i "s@^error_reporting =.*@error_reporting = E_ALL@" ${PHP_DIR}/etc/php.ini
RUN sed -i "s@^log_errors =.*@log_errors = On@" ${PHP_DIR}/etc/php.ini
RUN sed -i "s@^;error_log = php_errors.log.*@error_log = ${PHP_LOG_DIR}/php_errors.log@" ${PHP_DIR}/etc/php.ini

# php-fpm conf
RUN /bin/cp php-fpm.conf ${PHP_DIR}/etc/php-fpm.conf
RUN sed -i "s@^error_log =*@error_log = ${PHP_LOG_DIR}/php-fpm.log@" ${PHP_DIR}/etc/php-fpm.conf
RUN sed -i "s@^listen.owner.*@listen.owner = ${WWW_USER}@" ${PHP_DIR}/etc/php-fpm.conf
RUN sed -i "s@^listen.group.*@listen.group = ${WWW_USER}@" ${PHP_DIR}/etc/php-fpm.conf
RUN sed -i "s@^user =.*@user = ${WWW_USER}@" ${PHP_DIR}/etc/php-fpm.conf
RUN sed -i "s@^group =.*@group = ${WWW_USER}@" ${PHP_DIR}/etc/php-fpm.conf

RUN pushd ${SRC_DIR} && rm -rf php-${PHP_VER}
RUN /bin/cp opcache.ini ${PHP_INI_DIR}/opcache.ini
RUN sed -i "s@^opcache.memory_consumption.*@opcache.memory_consumption=${MEMORY_LIMIT}@" ${PHP_INI_DIR}/opcache.ini

# install swoole
# wget https://pecl.php.net/get/swoole-${SWOOLE_VER}.tgz
RUN tar xzf swoole-${SWOOLE_VER}.tgz \
  && pushd swoole-${SWOOLE_VER} \
  && ${PHP_DIR}/bin/phpize \
  && ./configure --enable-openssl --enable-http2 --with-php-config=${PHP_DIR}/bin/php-config \
  && make clean \
  && make -j && make install \
  && echo "extension=swoole.so" > ${PHP_INI_DIR}/swoole.ini \
  && popd \
  && rm -rf swoole-${SWOOLE_VER}

# install php-redis
# wget https://pecl.php.net/get/redis-${PHPREDIS_VER}.tgz
RUN tar xzf redis-${PHPREDIS_VER}.tgz \
  && pushd redis-${PHPREDIS_VER} \
  && ${PHP_DIR}/bin/phpize \
  && ./configure --with-php-config=${PHP_DIR}/bin/php-config \
  && make clean \
  && make && make install \
  && echo "extension=redis.so" > ${PHP_INI_DIR}/redis.ini \
  && popd \
  && rm -rf redis-${PHPREDIS_VER}

# install php-ds
# wget https://pecl.php.net/get/ds-${PHPDS_VER}.tgz
RUN tar xzf ds-${PHPDS_VER}.tgz \
  && pushd ds-${PHPDS_VER} \
  && ${PHP_DIR}/bin/phpize \
  && ./configure --with-php-config=${PHP_DIR}/bin/php-config \
  && make clean \
  && make && make install \
  && echo "extension=ds.so" > ${PHP_INI_DIR}/ds.ini \
  && popd \
  && rm -rf ds-${PHPDS_VER}

# install php-mcrypt
# wget https://pecl.php.net/get/mcrypt-${PHPMCRYPT_VER}.tgz
RUN tar xzf mcrypt-${PHPMCRYPT_VER}.tgz \
  && pushd mcrypt-${PHPMCRYPT_VER} \
  && ${PHP_DIR}/bin/phpize \
  && ./configure --with-php-config=${PHP_DIR}/bin/php-config \
  && make clean \
  && make && make install \
  && echo "extension=mcrypt.so" > ${PHP_INI_DIR}/mcrypt.ini \
  && popd \
  && rm -rf mcrypt-${PHPMCRYPT_VER}

# install inotify
# wget https://pecl.php.net/get/inotify-${PHPINOTIFY_VER}.tgz
RUN tar xzf inotify-${PHPINOTIFY_VER}.tgz \
  && pushd inotify-${PHPINOTIFY_VER} \
  && ${PHP_DIR}/bin/phpize \
  && ./configure --with-php-config=${PHP_DIR}/bin/php-config \
  && make clean \
  && make && make install \
  && echo "extension=inotify.so" > ${PHP_INI_DIR}/inotify.ini \
  && popd \
  && rm -rf inotify-${PHPINOTIFY_VER}

# install php-imagick
# wget https://pecl.php.net/get/imagick-${PHPIMAGICK_VER}.tgz
RUN tar xzf imagick-${PHPIMAGICK_VER}.tgz \
  && pushd imagick-${PHPIMAGICK_VER} \
  && ${PHP_DIR}/bin/phpize \
  && ./configure --with-php-config=${PHP_DIR}/bin/php-config --with-imagick \
  && make clean \
  && make && make install \
  && echo "extension=imagick.so" > ${PHP_INI_DIR}/imagick.ini \
  && popd \
  && rm -rf imagick-${PHPIMAGICK_VER}

# install xhprof
# wget https://github.com/longxinH/xhprof/archive/v${PHPXHPROF_VER}.tar.gz -O xhprof-${PHPXHPROF_VER}.tar.gz
RUN tar xzf xhprof-${PHPXHPROF_VER}.tar.gz \
  && pushd xhprof-${PHPXHPROF_VER}/extension \
  && ${PHP_DIR}/bin/phpize \
  && ./configure --with-php-config=${PHP_DIR}/bin/php-config \
  && make clean \
  && make && make install \
  && echo "extension=xhprof.so" > ${PHP_INI_DIR}/xhprof.ini \
  && popd \
  && rm -rf xhprof-${PHPXHPROF_VER}

# show modules
RUN echo $PATH && echo "php modules:" && ${PHP_DIR}/bin/php -m

# clear cache
RUN yum remove -y wget gcc gcc-c++ make cmake autoconf \
  && yum clean all
RUN rm -rf /var/cache/yum/*
RUN rm -rf /var/tmp/yum-*
RUN package-cleanup --quiet --leaves --exclude-bin | xargs yum remove -y
RUN rm -rf ${SRC_DIR}/* 
RUN history -c && history -w

# www work dir
RUN mkdir -p ${WWW_DIR}
WORKDIR ${WWW_DIR}

# volume
VOLUME ${PHP_ETC_DIR}
VOLUME ${PHP_DIR}/var

ENV PATH "$PATH:${PHP_DIR}/bin"
RUN echo $PATH

USER ${WWW_USER}
#CMD ${PHP_DIR}/sbin/php-fpm --daemonize --fpm-config ${PHP_ETC_DIR}/php-fpm.conf --pid ${PHP_DIR}/var/run/php-fpm.pid