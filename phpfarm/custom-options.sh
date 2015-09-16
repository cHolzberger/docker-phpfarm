# we need the correct path, is there a better way to find it?
if [ -d "/lib/i386-linux-gnu" ]; then
    LIBPATH="/lib/i386-linux-gnu/"
else
    LIBPATH="/lib/x86_64-linux-gnu/"
fi

etcbasedir="/etc/php/$version"
mkdir -p "$etcbasedir"


configoptions="$configoptions \
		--with-config-file-path=$etcbasedir
		--with-config-file-scan-dir=$etcbasedir/conf.d
    --enable-fastcgi \
    --with-bz2 \
    --with-curl \
    --with-gd \
    --with-jpeg-dir=/usr/lib \
    --with-png-dir=/usr/lib \
    --enable-gd-native-ttf \
    --with-ttf \
    --with-mhash \
    --with-mcrypt \
    --with-libdir=$LIBPATH \
		--with-regex=php \
		--enable-sysvsem \
		--enable-sysvshm \
		--enable-sysvmsg \
		--enable-track-vars \
		--enable-trans-sid \
		--enable-ctype \
		--without-gdbm \
		--with-iconv \
		--enable-filepro \
		--enable-shmop \
	 	--with-libxml-dir=/usr \
		--with-kerberos=/usr \
		--enable-dbx \
		--with-system-tzdata \
		--with-mysql=/usr \
		--with-mysqli=/usr/bin/mysql_config \
		--enable-pdo \
		--with-pdo-mysql=/usr \
		--enable-fastcgi \
		--enable-force-cgi-redirect \
		--with-curl \
		--enable-bcmath \
		--enable-calendar \
		--enable-exif \
		--enable-ftp \
		--with-gd \
		--with-jpeg-dir=/usr \
		--with-png-dir \
		--with-freetype-dir=/usr \
		--with-zlib-dir=/usr \
		--with-gettext=/usr \
		--enable-mbstring \
		--with-mcrypt=/usr \
		--with-mhash \
		--with-mime-magic \
		--enable-soap \
		--enable-sockets \
		--with-tidy \
		--enable-wddx \
		--with-xsl=/usr \
		--with-zip \
		--with-zlib \
		--enable-zip 
"


