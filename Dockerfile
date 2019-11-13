FROM centos:centos7

MAINTAINER kakuilan kakuilan@163.com

# dir and version
ENV SRC_DIR=/usr/local/src \
    WWW_DIR=/var/www \
    WWW_USER=www \
    MEMORY_LIMIT=512 \
    RE2C_VER=1.2.1 \
    LIBICONV_VER=1.16 \
    PHP_VER=7.2.24 \
    PHP_DIR=/usr/local/php \
    PHP_LOG_DIR=/var/log/php \
    PHP_ETC_DIR=/usr/local/php/etc \
    PHP_INI_DIR=/usr/local/php/php.d \
    SWOOLE_VER=4.3.3 \
    PHPDS_VER=1.2.9 \
    PHPMCRYPT_VER=1.0.3 \
    PHPREDIS_VER=5.1.1 \
    PHPIMAGICK_VER=3.4.4 \
    PHPINOTIFY_VER=2.0.0 \
    PHPMSGPACK_VER=2.0.3 \
    XHPROF_VER=2.1.0 \
    COMPOSER_HOME=/tmp

# make dir,add user
RUN mkdir -p ${SRC_DIR} ${WWW_DIR} \
  && useradd -M -s /sbin/nologin ${WWW_USER}

# copy files and add user
COPY conf pack ${SRC_DIR}/

# update yum repo
RUN yum install -y epel-release \
  && yum repolist \

# install tools
  && yum install -y \
	net-tools \
	telnet \
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
	libXpm-devel \
	libcurl-devel \
	libicu-devel \
	libidn-devel \
	libjpeg-devel \
	libjpeg-turbo-devel \
	libmcrypt-devel \
	libpng-devel \
	libsodium-devel \
	libtidy-devel \
	libwebp-devel \
	libxml2-devel \
	libxslt-devel \
	mhash-devel \
	net-snmp-devel \
	openssl-devel \
	pcre-devel \
	readline-devel \
	sqlite-devel \
	unixODBC-devel \
	zlib-devel \
  && yum clean all \
  && rm /var/log/* \

# begin install
  && pushd ${SRC_DIR} \
  && mkdir -p ${PHP_LOG_DIR} \
  && chmod -R a+rw ${PHP_LOG_DIR} \

# install re2c
  && wget https://github.com/skvadrik/re2c/releases/download/${RE2C_VER}/re2c-${RE2C_VER}.tar.xz -O re2c-${RE2C_VER}.tar.xz \
  && tar -xvJf re2c-${RE2C_VER}.tar.xz \
  && pushd re2c-${RE2C_VER} \
  && ./configure \
  && make clean \
  && make && make install \
  && popd \
  && rm -rf re2c-${RE2C_VER}* \

# install libiconv
  && wget https://ftp.gnu.org/pub/gnu/libiconv/libiconv-${LIBICONV_VER}.tar.gz \
  && tar xzf libiconv-${LIBICONV_VER}.tar.gz \
  && pushd libiconv-${LIBICONV_VER} \
  && ./configure --prefix=/usr/local \
  && make clean \
  && make && make install \
  && popd \
  && rm -rf libiconv-${LIBICONV_VER}* \

# ldconf libs
  && echo "include /etc/ld.so.conf.d/*.conf" > /etc/ld.so.conf \
  && echo '/usr/local/lib' > /etc/ld.so.conf \
  && ldconfig -f /etc/ld.so.conf \

# install php
  && wget http://hk1.php.net/get/php-${PHP_VER}.tar.gz/from/this/mirror -O php-${PHP_VER}.tar.gz \
  && tar xzf php-${PHP_VER}.tar.gz \
  && pushd php-${PHP_VER} \
  && ./buildconf --force \
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
  && make install \

# php path and conf
  && mkdir -p ${PHP_INI_DIR} \
  && ln -sf ${PHP_DIR}/bin/php /usr/local/bin/php \
  && /bin/mv ${SRC_DIR}/php-${PHP_VER}/php.ini-production ${PHP_DIR}/etc/php.ini \
  && /bin/mv ${SRC_DIR}/cacert.pem ${PHP_ETC_DIR}/cert.pem \
  && /bin/mv ${SRC_DIR}/opcache.ini ${PHP_INI_DIR}/opcache.ini \
  && /bin/mv ${SRC_DIR}/php-fpm.conf ${PHP_ETC_DIR}/php-fpm.conf \
  && pushd ${SRC_DIR} && rm -rf php-${PHP_VER}* \

# modify php.ini
  && sed -i "s@^memory_limit.*@memory_limit = ${MEMORY_LIMIT}M@" ${PHP_DIR}/etc/php.ini \
  && sed -i 's@^output_buffering =@output_buffering = On\noutput_buffering =@' ${PHP_DIR}/etc/php.ini \
  && sed -i 's@^;cgi.fix_pathinfo.*@cgi.fix_pathinfo=0@' ${PHP_DIR}/etc/php.ini \
  && sed -i 's@^short_open_tag = Off@short_open_tag = On@' ${PHP_DIR}/etc/php.ini \
  && sed -i 's@^expose_php = On@expose_php = Off@' ${PHP_DIR}/etc/php.ini \
  && sed -i 's@^request_order.*@request_order = "CGP"@' ${PHP_DIR}/etc/php.ini \
  && sed -i 's@^;date.timezone.*@date.timezone = Asia/Shanghai@' ${PHP_DIR}/etc/php.ini \
  && sed -i 's@^post_max_size.*@post_max_size = 32M@' ${PHP_DIR}/etc/php.ini \
  && sed -i 's@^upload_max_filesize.*@upload_max_filesize = 32M@' ${PHP_DIR}/etc/php.ini \
  && sed -i 's@^max_execution_time.*@max_execution_time = 120@' ${PHP_DIR}/etc/php.ini \
  && sed -i 's@^;realpath_cache_size.*@realpath_cache_size = 2M@' ${PHP_DIR}/etc/php.ini \
  && sed -i 's@^disable_functions.*@disable_functions = system,chroot,chgrp,chown,shell_exec,ini_alter,ini_restore,dl,readlink,symlink,popepassthru,stream_socket_server@' ${PHP_DIR}/etc/php.ini \
  && sed -i 's@^;sendmail_path.*@sendmail_path = /usr/sbin/sendmail -t -i@' ${PHP_DIR}/etc/php.ini \
  && sed -i "s@^;curl.cainfo.*@curl.cainfo = ${PHP_ETC_DIR}/cert.pem@" ${PHP_DIR}/etc/php.ini \
  && sed -i "s@^;openssl.cafile.*@openssl.cafile = ${PHP_ETC_DIR}/cert.pem@" ${PHP_DIR}/etc/php.ini \
  && sed -i "s@^error_reporting =.*@error_reporting = E_ALL@" ${PHP_DIR}/etc/php.ini \
  && sed -i "s@^log_errors =.*@log_errors = On@" ${PHP_DIR}/etc/php.ini \
  && sed -i "s@^;error_log = php_errors.log.*@error_log = ${PHP_LOG_DIR}/php_errors.log@" ${PHP_DIR}/etc/php.ini \

# php-fpm conf
  && sed -i "s@^error_log =.*@error_log = ${PHP_LOG_DIR}/php-fpm.log@" ${PHP_DIR}/etc/php-fpm.conf \
  && sed -i "s@^listen.owner.*@listen.owner = ${WWW_USER}@" ${PHP_DIR}/etc/php-fpm.conf \
  && sed -i "s@^listen.group.*@listen.group = ${WWW_USER}@" ${PHP_DIR}/etc/php-fpm.conf \
  && sed -i "s@^user =.*@user = ${WWW_USER}@" ${PHP_DIR}/etc/php-fpm.conf \
  && sed -i "s@^group =.*@group = ${WWW_USER}@" ${PHP_DIR}/etc/php-fpm.conf \

# opcache.ini
  && sed -i "s@^opcache.memory_consumption.*@opcache.memory_consumption=${MEMORY_LIMIT}@" ${PHP_INI_DIR}/opcache.ini \

# install swoole
  && wget https://pecl.php.net/get/swoole-${SWOOLE_VER}.tgz \
  && tar xzf swoole-${SWOOLE_VER}.tgz \
  && pushd swoole-${SWOOLE_VER} \
  && ${PHP_DIR}/bin/phpize \
  && ./configure --enable-openssl --enable-http2 --enable-sockets --enable-mysqlnd --with-php-config=${PHP_DIR}/bin/php-config \
  && make clean \
  && make -j && make install \
  && echo "extension=swoole.so" > ${PHP_INI_DIR}/swoole.ini \
  && popd \
  && rm -rf swoole-${SWOOLE_VER}* \

# install php-redis
  && wget https://pecl.php.net/get/redis-${PHPREDIS_VER}.tgz \
  && tar xzf redis-${PHPREDIS_VER}.tgz \
  && pushd redis-${PHPREDIS_VER} \
  && ${PHP_DIR}/bin/phpize \
  && ./configure --with-php-config=${PHP_DIR}/bin/php-config \
  && make clean \
  && make && make install \
  && echo "extension=redis.so" > ${PHP_INI_DIR}/redis.ini \
  && popd \
  && rm -rf redis-${PHPREDIS_VER}* \

# install php-ds
  && wget https://pecl.php.net/get/ds-${PHPDS_VER}.tgz \
  && tar xzf ds-${PHPDS_VER}.tgz \
  && pushd ds-${PHPDS_VER} \
  && ${PHP_DIR}/bin/phpize \
  && ./configure --with-php-config=${PHP_DIR}/bin/php-config \
  && make clean \
  && make && make install \
  && echo "extension=ds.so" > ${PHP_INI_DIR}/ds.ini \
  && popd \
  && rm -rf ds-${PHPDS_VER}* \

# install php-mcrypt
  && wget https://pecl.php.net/get/mcrypt-${PHPMCRYPT_VER}.tgz \
  && tar xzf mcrypt-${PHPMCRYPT_VER}.tgz \
  && pushd mcrypt-${PHPMCRYPT_VER} \
  && ${PHP_DIR}/bin/phpize \
  && ./configure --with-php-config=${PHP_DIR}/bin/php-config \
  && make clean \
  && make && make install \
  && echo "extension=mcrypt.so" > ${PHP_INI_DIR}/mcrypt.ini \
  && popd \
  && rm -rf mcrypt-${PHPMCRYPT_VER}* \

# install inotify
  && wget https://pecl.php.net/get/inotify-${PHPINOTIFY_VER}.tgz \
  && tar xzf inotify-${PHPINOTIFY_VER}.tgz \
  && pushd inotify-${PHPINOTIFY_VER} \
  && ${PHP_DIR}/bin/phpize \
  && ./configure --with-php-config=${PHP_DIR}/bin/php-config \
  && make clean \
  && make && make install \
  && echo "extension=inotify.so" > ${PHP_INI_DIR}/inotify.ini \
  && popd \
  && rm -rf inotify-${PHPINOTIFY_VER}* \

# install php-imagick
  && wget https://pecl.php.net/get/imagick-${PHPIMAGICK_VER}.tgz \
  && tar xzf imagick-${PHPIMAGICK_VER}.tgz \
  && pushd imagick-${PHPIMAGICK_VER} \
  && ${PHP_DIR}/bin/phpize \
  && ./configure --with-php-config=${PHP_DIR}/bin/php-config --with-imagick \
  && make clean \
  && make && make install \
  && echo "extension=imagick.so" > ${PHP_INI_DIR}/imagick.ini \
  && popd \
  && rm -rf imagick-${PHPIMAGICK_VER}* \

# install msgpack
  && wget http://pecl.php.net/get/msgpack-${PHPMSGPACK_VER}.tgz \
  && tar xzf msgpack-${PHPMSGPACK_VER}.tgz \
  && pushd msgpack-${PHPMSGPACK_VER} \
  && ${PHP_DIR}/bin/phpize \
  && ./configure --with-php-config=${PHP_DIR}/bin/php-config \
  && make clean \
  && make && make install \
  && echo "extension=msgpack.so" > ${PHP_INI_DIR}/msgpack.ini \
  && popd \
  && rm -rf msgpack-${PHPMSGPACK_VER}* \

# install xhprof
  && wget https://github.com/longxinH/xhprof/archive/v${XHPROF_VER}.tar.gz -O xhprof.${XHPROF_VER}.tar.gz \
  && tar xzf xhprof.${XHPROF_VER}.tar.gz \
  && pushd xhprof-${XHPROF_VER}/extension \
  && ${PHP_DIR}/bin/phpize \
  && ./configure --with-php-config=${PHP_DIR}/bin/php-config \
  && make clean \
  && make && make install \
  && echo ";extension=xhprof.so" > ${PHP_INI_DIR}/xhprof.ini \
  && popd \
  && rm -rf xhprof-${XHPROF_VER}* \

# install composer
  && wget https://getcomposer.org/installer -O installer.php \
  && ${PHP_DIR}/bin/php installer.php --no-ansi --install-dir=/usr/local/bin --filename=composer \
  && chmod +x /usr/local/bin/composer && composer self-update --clean-backups \
  && rm -f installer.php \

# install phpunit
  && wget https://phar.phpunit.de/phpunit-8.phar -O /usr/local/bin/phpunit \
  && chmod +x /usr/local/bin/phpunit \

# clear cache
  && yum remove -y epel-release wget gcc gcc-c++ make cmake autoconf \
  && set -o pipefail && find / -name "*.log" | xargs rm -f \
  && set -o pipefail && package-cleanup --quiet --leaves --exclude-bin | xargs yum remove -y \
  && yum clean all \
  && rm -rf ${SRC_DIR}/* \
  && rm -rf /var/cache/yum/* \
  && rm -rf /run/log/journal/* \
  && rm -rf /tmp/sess_* \
  && rm -rf /tmp/systemd-private-* \
  && rm -rf /tmp/yum_save* \
  && rm -rf /var/log/anaconda* \
  && rm -rf /var/log/audit* \
  && rm -rf /var/log/boot.log* \
  && rm -rf /var/log/btmp* \
  && rm -rf /var/log/chrony* \
  && rm -rf /var/log/cron* \
  && rm -rf /var/log/dmesg* \
  && rm -rf /var/log/firewalld* \
  && rm -rf /var/log/lastlog* \
  && rm -rf /var/log/messages* \
  && rm -rf /var/log/secure* \
  && rm -rf /var/log/tallylog* \
  && rm -rf /var/log/tuned/* \
  && rm -rf /var/log/wtmp* \
  && rm -rf /var/tmp/systemd-private* \
  && rm -rf /var/tmp/yum* \
  && rm -rf /usr/local/share/man/* \
  && rm -rf /usr/local/share/doc/* \
  && rm -rf /usr/share/doc/* \
  && rm -rf /usr/share/licenses/* \
  && rm -rf /usr/share/man/* \
  && history -c && history -w

# www work dir
WORKDIR ${WWW_DIR}

# volume
VOLUME ${PHP_ETC_DIR}

ENV PATH "$PATH:${PHP_DIR}/bin"

CMD ${PHP_DIR}/sbin/php-fpm