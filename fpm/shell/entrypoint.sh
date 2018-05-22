#!/bin/bash

#########################################################
# The following should be run only if Koken hasn't been #
# installed yet                                         #
#########################################################


  # set Koken database and db host
  DATABASE_PASSWORD="${DATABASE_PASSWORD:-koken}"
  DATABASE_HOST="${DATABASE_HOST:-db}"
  DATABASE_NAME="${DATABASE_NAME:-koken}"
  DATABASE_USER="${DATABASE_USER:-koken}"

  until nc ${DATABASE_HOST} 3306; do sleep 3; echo Using DB host: ${DATABASE_HOST}; echo "Waiting for DB to come up..."; done
  echo "DB is available now."

if [ ! -f /var/www/html/storage/configuration/database.php ] && [ ! -f /var/www/html/database.php ]; then

  echo "=> Setting up Koken"
  # Setup webroot
  rm -rf /var/www/html/*
  mkdir -p /var/www/html

  # Move install helpers into place
  mv /installer.php /var/www/html/installer.php
  mv /user_setup.php /var/www/html/user_setup.php
  mv /database.php /var/www/html/database.php

  # Configure Koken database connection
  sed -i -e "s/___PWD___/$DATABASE_PASSWORD/" /var/www/html/database.php
  sed -i -e "s/___DBHOST___/$DATABASE_HOST/" /var/www/html/database.php
  sed -i -e "s/___DBNAME___/$DATABASE_NAME/" /var/www/html/database.php
  sed -i -e "s/___DBUSER___/$DATABASE_USER/" /var/www/html/database.php

  chown www-data:www-data /var/www/html/
  chmod -R 755 /var/www/html
fi

################################################################
# The following should be run anytime the container is booted, #
# incase host is resized                                       #
################################################################

# Set PHP pools to take up to 1/2 of total system memory total, split between the two pools.
# 30MB per process is conservative estimate, is usually less than that
PHP_MAX=$(expr $(grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//') / 1024 / 2 / 30 / 2)
sed -i -e"s/pm.max_children = 5/pm.max_children = $PHP_MAX/" /usr/local/etc/php-fpm.d/www.conf
sed -i -e"s/pm.max_children = 5/pm.max_children = $PHP_MAX/" /usr/local/etc/php-fpm.d/images.conf

# set post_max_size and upload_max_filesize for the pools
PHP_MAX_FILESIZE="${PHP_MAX_FILESIZE:-100m}"
read unit <<<${PHP_MAX_FILESIZE//[^a-zA-Z]/ }
read num1 <<<${PHP_MAX_FILESIZE//[^0-9]/ }
(( PHP_POST_MAX_SIXE = num1 + 1 ))
echo "##################################################################################"
echo "## configurting php upload max filesize ##"
echo "## Setting post_max_size to ${PHP_POST_MAX_SIXE}${unit} ##"
echo "## Setting upload_max_filesize to ${PHP_MAX_FILESIZE} ##"
echo "##################################################################################\n"

echo "php_admin_value[post_max_size] = ${PHP_POST_MAX_SIXE}${unit}" >> /usr/local/etc/php-fpm.d/www.conf
echo "php_admin_value[upload_max_filesize] = ${PHP_MAX_FILESIZE}" >> /usr/local/etc/php-fpm.d/www.conf
echo "php_admin_value[post_max_size] = ${PHP_POST_MAX_SIXE}${unit}" >> /usr/local/etc/php-fpm.d/images.conf
echo "php_admin_value[upload_max_filesize] = ${PHP_MAX_FILESIZE}" >> /usr/local/etc/php-fpm.d/images.conf


# Initiliaze koken
# rm -f /var/www/html/ready.txt;

if [ -f /var/www/html/installer.php ] && [ ! -f /var/www/html/ready.txt ]; then
  echo "##################################################################################"
  echo "##Running silent install, will take a couple of minutes, so go and take a tea...##"
  echo "##################################################################################\n"

  wget --quiet --cache=off --dns-timeout=10 -O /var/www/html/core.zip https://s3.amazonaws.com/koken-installer/releases/latest.zip
  wget --quiet --cache=off --dns-timeout=10 -O /var/www/html/elementary.zip https://koken-store.s3.amazonaws.com/plugins/be1cb2d9-ed05-2d81-85b4-23282832eb84.zip

  cd /var/www/html;

  unzip core.zip;
  unzip elementary.zip;

  rm *.zip;

  mv be1cb2d9-ed05-2d81-85b4-23282832eb84 storage/themes/elementary;
  mv database.php storage/configuration;
  mv user_setup.php storage/configuration;

  touch /var/www/html/ready.txt;

  # Disable google maps
  sed -i 's|.*maps.googleapis.com/maps.*|<!-- script src="https://maps.googleapis.com/maps/api/js?v=3.exp\&sensor=false"></script -->|' /var/www/html/admin/index.html

  # Disable remote jquery.min.js
  sed -i 's|.*ajax.googleapis.com/ajax.*|<script src="/app/site/themes/common/js/jquery.min.js"></script>|' /var/www/html/app/site/site.php

  # Download OxyGen theme
  cd /tmp && wget https://github.com/blacs30/OxyGen/archive/master.zip
  unzip /tmp/master.zip
  mv /tmp/OxyGen-master/OxyGen /var/www/html/storage/themes/

  chown -R www-data:www-data /var/www/html;

  echo "##################################################################################"
  echo "##Koken is ready to use, enjoy it##############################################"
  echo "##################################################################################"

fi;

echo "Ready to use koken..."

exec "$@"
