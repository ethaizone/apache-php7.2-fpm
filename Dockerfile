FROM ubuntu:16.04
MAINTAINER krutpong@gmail.com

#add Thailand repo
RUN echo "deb http://th.archive.ubuntu.com/ubuntu/ xenial main restricted" > /etc/apt/sources.list && \
    echo "deb http://th.archive.ubuntu.com/ubuntu/ xenial-updates main restricted" >> /etc/apt/sources.list && \
    echo "deb http://th.archive.ubuntu.com/ubuntu/ xenial universe" >> /etc/apt/sources.list && \
    echo "deb http://th.archive.ubuntu.com/ubuntu/ xenial-updates universe" >> /etc/apt/sources.list && \
    echo "deb http://th.archive.ubuntu.com/ubuntu/ xenial multiverse" >> /etc/apt/sources.list && \
    echo "deb http://th.archive.ubuntu.com/ubuntu/ xenial-updates multiverse" >> /etc/apt/sources.list && \
    echo "deb http://th.archive.ubuntu.com/ubuntu/ xenial-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://th.archive.ubuntu.com/ubuntu/ xenial-security main restricted" >> /etc/apt/sources.list && \
    echo "deb http://th.archive.ubuntu.com/ubuntu/ xenial-security universe" >> /etc/apt/sources.list && \
    echo "deb http://th.archive.ubuntu.com/ubuntu/ xenial-security multiverse" >> /etc/apt/sources.list && \
    apt-get update

RUN apt-get install -y software-properties-common
RUN apt-get install -y python-software-properties
RUN LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
RUN apt-get update

#setup timezone
RUN apt-get install -y tzdata
RUN echo "Asia/Kolkata" > /etc/timezone \
    rm /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

#setup supervisor
RUN apt-get install -y supervisor
RUN mkdir -p /var/log/supervisor

#setup apache
RUN apt-get install -y apache2
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

RUN mkdir -p /var/lock/apache2 /var/run/apache2

COPY sites-available /etc/apache2/sites-available/

RUN sed -i 's/CustomLog/#CustomLog/' /etc/apache2/conf-available/other-vhosts-access-log.conf

#setup git
RUN apt-get install -y git

#setup nano
RUN apt-get install -y nano

#setup php
RUN apt-get install -y libapache2-mod-fastcgi
RUN apt-get install -y php-fpm
RUN apt-get install -y gcc
RUN apt-get install -y libpcre3-dev
RUN apt-get install -y php-mysql
RUN apt-get install -y php-mcrypt
RUN apt-get install -y pwgen
RUN apt-get install -y php-cli
RUN apt-get install -y php-curl
RUN apt-get install -y php-sqlite3
RUN apt-get install -y php-apcu
RUN apt-get install -y php-memcached
RUN apt-get install -y php-redis
RUN apt-get install -y php-dev
RUN apt-get install -y php-gd
RUN apt-get install -y php-pear
RUN apt-get install -y php-mongodb
RUN apt-get install -y php-mbstring
RUN apt-get install -y imagemagick
RUN apt-get install -y php-imagick
RUN apt-get install -y php-mcrypt

#Pointing to php7.1-mcrypt with php7.2 will solve the issue here.
#Below are the steps to configure 7.1 version mcrypt with php7.2
RUN apt-get install -y php7.1-mcrypt
RUN ln -s /etc/php/7.1/mods-available/mcrypt.ini /etc/php/7.2/mods-available/
RUN phpenmod mcrypt


RUN a2enconf php7.2-fpm
RUN a2dismod mpm_prefork
RUN a2enmod mpm_event alias
RUN a2enmod fastcgi proxy_fcgi


RUN apt-get clean
EXPOSE 8080

COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ADD config/index.html /var/www/index.html
ADD config/index.php /var/www/index.php
COPY config/apache2.conf /etc/apache2/apache2.conf

COPY config/apache_enable.sh apache_enable.sh
RUN chmod 744 apache_enable.sh

#VOLUME ["/var/lib/mysql"]
VOLUME ["/var/www","/var/www"]
RUN service php7.2-fpm start
CMD ["/usr/bin/supervisord"]









