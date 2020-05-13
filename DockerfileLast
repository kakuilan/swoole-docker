##########################
# Build the release image.
FROM centos:centos7

# dir and version
ARG SRC_DIR=/usr/local/src
ARG WWW_USER=www

# dir and version
ENV WWW_DIR=/var/www \
    PHP_DIR=/usr/local/php \
    PHP_BIN_DIR=/usr/local/php/bin \
    PHP_ETC_DIR=/usr/local/php/etc \
    PHP_INI_DIR=/usr/local/php/php.d \
    PHP_LOG_DIR=/var/log/php \
    COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_HOME=/usr/local/php/composer \
    COMPOSER_CACHE_DIR=/usr/local/php/composer/cache

# install tools
RUN yum install -y \
	bzip2 \
	net-tools \
	tcpdump \
	telnet \
	which \
	unzip \

# download and uncompress package
    && cd ${SRC_DIR} \
    && mkdir -p /usr/local/lib \
    && curl -OL https://raw.githubusercontent.com/imblaine/phpbin/master/snmp.tar.bz2 \
    && tar -jxf snmp.tar.bz2 -C / \
    && rm snmp.tar.bz2 \
    && curl -OL https://raw.githubusercontent.com/imblaine/phpbin/master/mylibs.tar.bz2 \
    && tar -jxf mylibs.tar.bz2 -C ./ \
    && /bin/mv -f mylibs/libiconv.la mylibs/libiconv.so mylibs/libiconv.so.2 mylibs/libiconv.so.2.6.1 -t /usr/local/lib/ \
    && /bin/mv -f mylibs/libhiredis.a mylibs/libhiredis.so mylibs/libhiredis.so.0.14 -t /usr/local/lib/ \
    && /bin/mv -f mylibs/* /usr/lib64/ \
    && rm mylibs.tar.bz2 \
    && curl -OL https://raw.githubusercontent.com/imblaine/phpbin/master/php.tar.bz2 \
    && tar -jxf php.tar.bz2 -C / \
    && rm -rf ${SRC_DIR}/* \

# ldconfig
    && du -h /usr/local/php \
    && echo "include /etc/ld.so.conf.d/*.conf" > /etc/ld.so.conf \
    && echo '/usr/local/lib' >> /etc/ld.so.conf \
    && echo '/usr/local/lib64' >> /etc/ld.so.conf \
    && echo '/usr/lib' >> /etc/ld.so.conf \
    && echo '/usr/lib64' >> /etc/ld.so.conf \
    && ldconfig -f /etc/ld.so.conf \

# make www dir add user
    && mkdir -p ${WWW_DIR} /var/lib/net-snmp/cert_indexes /var/lib/net-snmp/mib_indexes \
    && useradd -M -s /sbin/nologin ${WWW_USER} \
    && rm -rf /var/log/* \
    && mkdir -p ${PHP_LOG_DIR} \
    && chmod -R a+rw ${PHP_LOG_DIR} \

# clear cache
    && yum clean all \
    && rm -rf /var/cache/yum/* \
    && rm -rf /run/log/* \
    && rm -rf /tmp/yum_save* \
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

ENV PATH "$PATH:${PHP_BIN_DIR}"

CMD ${PHP_DIR}/sbin/php-fpm