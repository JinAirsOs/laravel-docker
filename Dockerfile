FROM ubuntu:trusty
MAINTAINER Ninjia Pan <ninjia.pan@btcc.com>

# upgrade the container
RUN apt-get update && \
    apt-get upgrade -y

# install some prerequisites
RUN apt-get install -y software-properties-common curl build-essential \
    dos2unix gcc git libmcrypt4 libpcre3-dev memcached make python2.7-dev \
    python-pip re2c unattended-upgrades whois vim libnotify-bin nano wget \
    debconf-utils

# add some repositories
RUN apt-add-repository ppa:nginx/stable -y && \
    apt-get update && \
    apt-get -y install nginx
# install nginx
RUN rm -rf /etc/nginx/nginx.conf && \
    rm -rf /etc/nginx/sites-available/default && \
    rm -rf /etc/nginx/sites-enabled/default
COPY example.oauth.btcc.com /etc/nginx/sites-enabled/oauth.btcc.com
COPY example.nginx.conf /etc/nginx/nginx.conf
RUN usermod -u 1000 www-data && \
    chown -Rf www-data.www-data /var/www/html/
VOLUME ["/var/log/nginx"]

# set the locale
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale  && \
    locale-gen en_US.UTF-8  && \
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# install php
RUN apt-get install -y python-software-properties software-properties-common && \
    LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php -y && \
    apt-get update
RUN apt-get install -y --force-yes php7.0-fpm php7.0-cli php7.0-dev php7.0-pgsql php7.0-sqlite3 php7.0-gd \
    php-apcu php7.0-curl php7.0-mcrypt php7.0-imap php7.0-mysql php7.0-readline php-xdebug php-common \
    php7.0-mbstring php7.0-xml php7.0-zip
RUN sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/cli/php.ini && \
    sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.0/cli/php.ini && \
    sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.0/cli/php.ini && \
    sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/fpm/php.ini && \
    sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.0/fpm/php.ini && \
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.0/fpm/php.ini && \
    sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/7.0/fpm/php.ini && \
    sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/7.0/fpm/php.ini && \
    sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.0/fpm/php.ini && \
    sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.0/fpm/php-fpm.conf && \
    sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i -e "s/pm.max_children = 5/pm.max_children = 9/g" /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i -e "s/pm.start_servers = 2/pm.start_servers = 3/g" /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 2/g" /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 4/g" /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i -e "s/pm.max_requests = 500/pm.max_requests = 200/g" /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i -e "s/;listen.mode = 0660/listen.mode = 0750/g" /etc/php/7.0/fpm/pool.d/www.conf && \
    find /etc/php/7.0/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;
RUN mkdir -p /run/php/ && chown -Rf www-data.www-data /run/php

# install sqlite 
RUN apt-get install -y sqlite3 libsqlite3-dev

# install mysql 
RUN { \
        echo mysql-community-server mysql-community-server/data-dir select ''; \
        echo mysql-community-server mysql-community-server/root-pass password 'secret'; \
        echo mysql-community-server mysql-community-server/re-root-pass password 'secret'; \
        echo mysql-community-server mysql-community-server/remove-test-db select false; \
    } | debconf-set-selections \
    && apt-get update && apt-get install -y mysql-server && \
    echo "default_password_lifetime = 0" >> /etc/mysql/my.cnf && \
    sed -i '/^bind-address/s/bind-address.*=.*/bind-address = 0.0.0.0/' /etc/mysql/my.cnf
RUN /usr/sbin/mysqld & \
    sleep 10s && \
    echo "GRANT ALL ON *.* TO root@'0.0.0.0' IDENTIFIED BY 'secret' WITH GRANT OPTION; CREATE USER 'homestead'@'0.0.0.0' IDENTIFIED BY 'secret'; GRANT ALL ON *.* TO 'homestead'@'0.0.0.0' IDENTIFIED BY 'secret' WITH GRANT OPTION; GRANT ALL ON *.* TO 'homestead'@'%' IDENTIFIED BY 'secret' WITH GRANT OPTION; FLUSH PRIVILEGES; CREATE DATABASE homestead;USE homestead;CREATE TABLE migrations ( id int(10) unsigned NOT NULL AUTO_INCREMENT,migration varchar(255) NOT NULL,batch int(11) NOT NULL,PRIMARY KEY (id)) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;INSERT INTO migrations VALUES (1,'2014_10_12_000000_create_users_table',1),(2,'2014_10_12_100000_create_password_resets_table',1),(3,'2017_08_08_032219_update_users_table_to_support_migration',1),(4,'2017_08_08_103102_create_sessions_table',1),(5,'2017_08_11_113351_make_user_nickname_nullable',1),(6,'2017_08_14_151741_add_user_is_old_flag',1);CREATE TABLE password_resets (email varchar(255) NOT NULL,token varchar(255) NOT NULL,created_at timestamp NULL DEFAULT NULL,KEY password_resets_email_index (email)) ENGINE=InnoDB DEFAULT CHARSET=utf8;CREATE TABLE sessions (id varchar(255) NOT NULL,user_id int(10) unsigned DEFAULT NULL,ip_address varchar(45) DEFAULT NULL,user_agent text,payload text NOT NULL,last_activity int(11) NOT NULL,UNIQUE KEY sessions_id_unique (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8;CREATE TABLE users (id int(10) unsigned NOT NULL AUTO_INCREMENT,name varchar(255) NOT NULL,email varchar(255) NOT NULL,password varchar(255) NOT NULL,remember_token varchar(100) DEFAULT NULL,created_at timestamp NULL DEFAULT NULL,updated_at timestamp NULL DEFAULT NULL,otpkey varchar(16) DEFAULT NULL,nickname varchar(255) DEFAULT NULL,is_old tinyint(1) NOT NULL DEFAULT '0',PRIMARY KEY (id),UNIQUE KEY users_email_unique (email),UNIQUE KEY users_name_unique (name)) ENGINE=InnoDB DEFAULT CHARSET=utf8;" | mysql

VOLUME ["/var/lib/mysql"]

# install composer
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    printf "\nPATH=\"~/.composer/vendor/bin:\$PATH\"\n" | tee -a ~/.bashrc
    
# install laravel envoy
RUN composer global require "laravel/envoy"

#install laravel installer
RUN composer global require "laravel/installer"

# install nodejs,gulp,bower
RUN curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash - && \
    apt-get install -y nodejs && \
    npm install -g gulp && \
    npm install -g bower

# install redis 
RUN apt-get install -y redis-server

# install supervisor
RUN apt-get install -y supervisor && \
    mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
VOLUME ["/var/log/supervisor"]

# clean up our mess
RUN apt-get remove --purge -y software-properties-common && \
    apt-get autoremove -y && \
    apt-get clean && \
    apt-get autoclean && \
    echo -n > /var/lib/apt/extended_states && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/man/?? && \
    rm -rf /usr/share/man/??_*
#add laravel cronjob
ADD crontab /etc/cron.d/laravel-cron
RUN chmod 0644 /etc/cron.d/laravel-cron

# expose ports
EXPOSE 80 443 3306 6379

# set workdir
WORKDIR /var/www/html/app

# set container entrypoints
ENTRYPOINT ["/bin/bash","-c"]
CMD ["/usr/bin/supervisord"]

