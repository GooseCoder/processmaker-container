FROM php:5.5-apache

RUN echo mysql-server-5.5 mysql-server/root_password password sample | debconf-set-selections
RUN echo mysql-server-5.5 mysql-server/root_password_again password sample | debconf-set-selections

RUN apt-get update && apt-get dist-upgrade -qq -y
RUN apt-get install -qq -y software-properties-common && \ 
    apt-get install -qq -y libmcrypt-dev mcrypt && \
    apt-get install -qq -y libpng12-dev && \
    apt-get install -qq -y libxml2-dev && \
    apt-get install -qq -y libldap2-dev && \
    apt-get install -qq -y libmemcached-dev zlib1g-dev libncurses5-dev && \
    apt-get install -qq -y git && \
    apt-get install -qq -y mysql-server-5.5 mysql-client-5.5

RUN a2enmod headers && a2enmod expires && a2enmod rewrite
RUN docker-php-ext-install mcrypt && \
    docker-php-ext-install gd && \
    docker-php-ext-install mysql && \
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-install mbstring && \
    docker-php-ext-install soap && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu && \
    docker-php-ext-install ldap

RUN curl -L https://pecl.php.net/get/xdebug-2.3.3.tgz >> /usr/src/php/ext/xdebug.tgz && \
tar -xf /usr/src/php/ext/xdebug.tgz -C /usr/src/php/ext/ && \
rm /usr/src/php/ext/xdebug.tgz && \
docker-php-ext-install xdebug-2.3.3

RUN curl -L https://pecl.php.net/get/apcu-4.0.7.tgz >> /usr/src/php/ext/apcu.tgz && \
tar -xf /usr/src/php/ext/apcu.tgz -C /usr/src/php/ext/ && \
rm /usr/src/php/ext/apcu.tgz && \
docker-php-ext-install apcu-4.0.7

RUN curl -L http://pecl.php.net/get/memcached-2.2.0.tgz >> /usr/src/php/ext/memcached.tgz && \
tar -xf /usr/src/php/ext/memcached.tgz -C /usr/src/php/ext/ && \
rm /usr/src/php/ext/memcached.tgz && \
docker-php-ext-install memcached-2.2.0

RUN cd /opt && \
    git clone --depth=1 https://github.com/colosa/processmaker.git && \ 
    cd processmaker && \
    sed -i -e 's/Order allow,deny//g' pmos.conf.example && \
    sed -i -e 's/allow from all/Require all Granted/g' pmos.conf.example && \
    sed -i -e 's/example\/path\/to/opt/g' pmos.conf.example && \      
    cp pmos.conf.example /etc/apache2/sites-available/processmaker.conf

RUN echo "<html>\
<head>\
<title>Redirector</title>\
<meta http-equiv=\"PRAGMA\" content=\"NO-CACHE\" />\
<meta http-equiv=\"CACHE-CONTROL\" content=\"NO-STORE\" />\
<meta http-equiv=\"REFRESH\" content=\"0;URL=sys/en/neoclassic/login/login\" />\
</head>\
</html>" > /opt/processmaker/workflow/public_html/index.html

RUN mkdir /opt/processmaker/workflow/engine/js/labels/ && \
    mkdir /opt/processmaker/workflow/public_html/translations/ && \
    chown -Rf www-data.www-data /opt/processmaker/

RUN a2dissite processmaker.conf && a2ensite processmaker.conf
