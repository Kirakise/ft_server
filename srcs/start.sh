#!/bin/bash

service mysql start

chown -R www-data /var/www/*
chmod -R 755 /var/www/*

sudo mkdir /var/run/php
sudo apt install --reinstall php-fpm
mkdir /var/www/site
echo "<?php phpinfo(); ?>" >> /var/www/site/index.php

mkdir /etc/nginx/ssl
openssl req -newkey rsa:4096 \
            -x509 \
            -sha256 \
            -days 3650 \
            -nodes \
            -out /etc/nginx/ssl/site.crt \
            -keyout /etc/nginx/ssl/site.key \
			-subj "/C=RU/ST=Moscow/L=Moscow/O=21school/OU=rcaraway/CN=site"

rm /etc/nginx/sites-enabled/default
mv ./tmp/nginx-conf /etc/nginx/sites-available/site
ln -s /etc/nginx/sites-available/site /etc/nginx/sites-enabled/site

echo "CREATE DATABASE wordpress;" | mysql -u root --skip-password
echo "GRANT ALL PRIVILEGES ON wordpress.* TO 'root'@'localhost' WITH GRANT OPTION;" | mysql -u root --skip-password
echo "update mysql.user set plugin='mysql_native_password' where user='root';" | mysql -u root --skip-password
echo "FLUSH PRIVILEGES;" | mysql -u root --skip-password

mkdir /var/www/site/phpmyadmin
wget https://files.phpmyadmin.net/phpMyAdmin/4.9.0.1/phpMyAdmin-4.9.0.1-all-languages.tar.gz
tar -xvf phpMyAdmin-4.9.0.1-all-languages.tar.gz --strip-components 1 -C /var/www/site/phpmyadmin
mv tmp/phpmyadmin.inc.php /var/www/site/phpmyadmin/config.inc.php

cd tmp
wget -c https://wordpress.org/latest.tar.gz
tar -xvzf latest.tar.gz
mv wordpress/ /var/www/site/
mv /tmp/wp-config.php /var/www/site/phpmyadmin/wordpress

service php7.3-fpm start
service nginx start
bash
