# swoole-docker
k`s SwooleDistributed php7 swoole docker image   
php的swoole镜像


#### 本镜像的系统和包
- centos7
- php 7.2.30
- swoole 4.2.13
- re2c 1.3
- libiconv 1.16
- php-ds 1.2.9
- php-imagick 3.4.4
- php-inotify 2.0.0
- php-mcrypt 1.0.3
- php-redis 5.2.2

#### php相关路径
- php目录 /usr/local/php/
- cli文件 /usr/local/php/bin/php
- fpm文件 /usr/local/php/sbin/php-fpm
- 配置目录 /usr/local/php/etc/
- 扩展配置目录 /usr/local/php/php.d/
- php配置文件 /usr/local/php/etc/php.ini
- fpm配置文件 /usr/local/php/etc/php-fpm.conf
- 日志目录 /var/log/php
- php日志 /var/log/php/php_errors.log
- fpm日志 /var/log/php/php-fpm.log
- composer /usr/local/bin/composer


#### 使用方法
```shell
#创建本地镜像
git clone https://github.com/kakuilan/swoole-docker.git
cd swoole-docker/
sudo docker build -t myimg .

#拉取网络镜像
sudo docker pull kakuilan/swoole-docker:latest
sudo docker run --rm -it kakuilan/swoole-docker:latest php -v
sudo docker run --rm -it kakuilan/swoole-docker:latest php --ri swoole
sudo docker run --rm -it kakuilan/swoole-docker:latest composer --version
sudo docker run --rm -it kakuilan/swoole-docker:latest phpunit --version

#php、phpunit和composer别名
echo "alias php='docker run --rm -it kakuilan/swoole-docker:latest php'" >> /etc/profile
echo "alias phpunit='docker run --rm -it --volume $PWD:/var/www kakuilan/swoole-docker:latest phpunit'" >> /etc/profile
echo "alias composer='docker run --rm -it --volume $PWD:/var/www kakuilan/swoole-docker:latest composer'" >> /etc/profile
source /etc/profile
php -v
phpunit --version
composer --version
```

#进入镜像
docker run --name test -it -v /var/www:/var/www -d 8df301a8a060 php -S localhost:8000
docker exec -it test /bin/bash

#拷贝库文件
docker run --name test -it -v /var/www:/var/www -d 8df301a8a060 php -S localhost:8000
docker exec -it test /bin/bash
cd /usr/local/src/
mkdir -p mylibs
ll -h /usr/lib64 |grep libjbig
\cp -drf /usr/lib64/libtiff* mylibs/
\cp -drf /usr/lib64/libfontconfig.* mylibs/
\cp -drf /usr/lib64/libXext.* mylibs/
\cp -drf /usr/lib64/libXt.* mylibs/
\cp -drf /usr/lib64/libSM.* mylibs/
\cp -drf /usr/lib64/libICE.* mylibs/
\cp -drf /usr/lib64/libgomp.* mylibs/
\cp -drf /usr/lib64/libjbig* mylibs/
tar -jcf mylibs.tar.bz2 ./mylibs
mv mylibs.tar.bz2 /var/www/

#发布镜像
sudo docker tag myimg:latest kakuilan/swoole-docker:0.0.5
sudo docker push kakuilan/swoole-docker:0.0.5

#### php所含的扩展
- PDO
- PDO_ODBC
- Phar 2.0.2
- Reflection
- SPL
- SimpleXML
- Zend OPcache
- bcmath
- bz2 1.0.6
- calendar
- ctype
- curl 7.29.0
- date
- dba
- dom
- ds 1.2.8
- exif 7.2.16
- fileinfo 1.0.5
- filter
- ftp
- gd 2.1.0
- gettext
- gmp 6.0.0
- hash
- iconv 2.17
- imagick 3.4.3
- inotify 2.0.0
- intl 1.1.0
- json 1.6.0
- libxml 2.9.1
- mbstring
- mcrypt 2.5.8
- msgpack 2.0.3
- mysqli
- mysqlnd
- odbc
- openssl 1.0.2k
- pcntl
- pcre 8.41
- pdo_mysql
- pdo_sqlite 3.20.1
- posix
- readline 6.2
- redis 4.3.0
- session
- shmop
- snmp 5.7.2
- soap
- sockets
- sodium 1.0.16
- sqlite3 7.2.13
- standard
- swoole 4.3.3
- sysvmsg
- sysvsem
- sysvshm
- tidy 5.4.0
- tokenizer
- wddx
- xhprof 2.1.0
- xml 2.9.1
- xmlreader
- xmlrpc
- xmlwriter
- xsl 1.1.28
- zip 1.15.4
- zlib 1.2.7

