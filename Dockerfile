#
# PHP Farm Docker image
#

# we use Debian as the host OS
FROM debian:jessie

MAINTAINER Christian Holzberger, ch@mosaiksoftware.de

# get sources 
COPY source.list /etc/apt/sources.list
# add hhvm key
ENV DEBIAN_FRONTEND noninteractive
# make php 5.3 work again
ENV LDFLAGS "-lssl -lcrypto"
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449 
# add some build tools
RUN apt-get update && \
    apt-get install -y \
    hhvm \    
    apache2 \
    apache2-mpm-prefork \
    git \
    build-essential \
    wget \
    pkg-config \
    curl \
    libapache2-mod-fcgid \
    fontconfig \
    libxrender1 \
    xfonts-base \
    xfonts-75dpi \
    libssl1.0.0 \
    libssl1.0.0-dbg

RUN a2enmod rewrite
#add build deps manually
RUN apt-get install -y libfreetype6-dev \
    libbz2-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libxpm-dev \
    libmcrypt-dev \
    libltdl-dev \
    libmhash-dev \
    libssl-dev

RUN apt-get install -y lemon
#php5 build deps
RUN apt-get build-dep -y php5 
# wkhtmltopdf offical binary
RUN wget http://download.gna.org/wkhtmltopdf/0.12/0.12.2.1/wkhtmltox-0.12.2.1_linux-jessie-amd64.deb -O /tmp/wkhtmltox.deb && dpkg -i /tmp/wkhtmltox.deb && rm /tmp/wkhtmltox.deb

RUN wget https://files.phpmyadmin.net/phpMyAdmin/4.4.11/phpMyAdmin-4.4.11-all-languages.tar.gz -O /tmp/phpmyadmin.tar.gz \
&& cd /opt \
&& tar xzf /tmp/phpmyadmin.tar.gz \
&& mv phpMyAdmin-4.4.7-english/ phpmyadmin \
&& chown www-data:www-data /opt/phpmyadmin

COPY phpmyadmin /opt/phpmyadmin
#freetype build fix
RUN mkdir /usr/include/freetype2/freetype/ && ln -s /usr/include/freetype2/freetype.h /usr/include/freetype2/freetype/freetype.h

# add customized configuration
COPY phpfarm /tmp/phpfarm
# install and run the phpfarm script
# compile, then delete sources (saves space)
RUN git clone git://git.code.sf.net/p/phpfarm/code phpfarm \
&& cp -r /tmp/phpfarm/* /phpfarm/src \
&& cd /phpfarm/src && \
    ./compile.sh 5.3.29 && \
    ./compile.sh 5.4.32 && \
    ./compile.sh 5.5.16 && \
    ./compile.sh 5.6.1 && \
    rm -rf /phpfarm/src && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#set short_open_tag
RUN sed -e "s/short_open_tag = Off/short_open_tag = On/g" -i /phpfarm/inst/php-*/lib/php.ini
RUN sed -e "s/error_log = syslog/error_log = \/var\/log\/php.log/g" -i /phpfarm/inst/php-*/lib/php.ini

RUN touch /var/log/php.log && chmod a+rw /var/log/php.log
# reconfigure Apache
RUN rm -rf /var/www/*

COPY var-www /var/www/
COPY apache  /etc/apache2/

RUN apt-get remove -y mysql-server-5.5
RUN a2enmod rewrite proxy proxy_fcgi
RUN a2enconf phpfarm
RUN a2ensite hhvm php-5.3 php-5.4 php-5.5 php-5.6

# set path
ENV PATH /phpfarm/inst/bin/:/usr/sbin:/usr/bin:/sbin:/bin

# expose the ports
EXPOSE 8050 8053 8054 8055 8056

# run it
COPY run.sh /run.sh
ENTRYPOINT ["/bin/bash"]
CMD ["/run.sh"]
