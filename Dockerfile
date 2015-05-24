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
    xfonts-75dpi 

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
    libmhash-dev

#php5 build deps
RUN apt-get build-dep -y php5 
# wkhtmltopdf offical binary
RUN wget http://downloads.sourceforge.net/project/wkhtmltopdf/0.12.2.1/wkhtmltox-0.12.2.1_linux-jessie-amd64.deb -O /tmp/wkhtmltox.deb && dpkg -i /tmp/wkhtmltox.deb && rm /tmp/wkhtmltox.deb

# add customized configuration
COPY phpfarm /tmp/phpfarm
# install and run the phpfarm script
# compile, then delete sources (saves space)
RUN git clone git://git.code.sf.net/p/phpfarm/code phpfarm \
&& cp -r /tmp/phpfarm/* /phpfarm/src \
&& cd /phpfarm/src && \
    ./compile.sh 5.2.17 && \
    ./compile.sh 5.3.29 && \
    ./compile.sh 5.4.32 && \
    ./compile.sh 5.5.16 && \
    ./compile.sh 5.6.1 && \
    rm -rf /phpfarm/src && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# reconfigure Apache
RUN rm -rf /var/www/*

COPY var-www /var/www/
COPY apache  /etc/apache2/

RUN apt-get remove -y mysql-server-5.5
RUN a2ensite php-5.2 php-5.3 php-5.4 php-5.5 php-5.6
RUN a2enmod rewrite

# set path
ENV PATH /phpfarm/inst/bin/:/usr/sbin:/usr/bin:/sbin:/bin

# expose the ports
EXPOSE 8050 8052 8053 8054 8055 8056

# run it
COPY run.sh /run.sh
ENTRYPOINT ["/bin/bash"]
CMD ["/run.sh"]
