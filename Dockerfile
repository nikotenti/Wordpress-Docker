# Basato su ubuntu: ultima versione
FROM ubuntu:latest

MAINTAINER Nicholas Tenti <nikotenti@outlook.it>

# Aggiorno le repository ed il sistema
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install apt-utils
# Installo le dipendenze
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install sudo nano vim coreutils curl systemd apache2 apache2-utils mariadb-server php libapache2-mod-php php-mysql php-curl php-gd php-xml php-mbstring  php-xmlrpc php-zip php-soap php-intl phpmyadmin

# Imposto variabili password
ARG root_password
ARG wp_password
ARG phpmyadmin_pass

# Configuro Apache2
RUN a2enmod rewrite
RUN chown -R www-data:www-data /var/www
RUN chown -R root:root /var/www/html
RUN rm /var/www/html/index.html

# Imposto variabili Apache2
ENV APACHE_RUN_USER  www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR   /var/log/apache2
ENV APACHE_PID_FILE  /var/run/apache2/apache2.pid
ENV APACHE_RUN_DIR   /var/run/apache2
ENV APACHE_LOCK_DIR  /var/lock/apache2
ENV APACHE_LOG_DIR   /var/log/apache2

# Imposto variabili MySQL
ENV MYSQL_DATA_DIR=/var/lib/mysql 
ENV MYSQL_RUN_DIR=/run/mysqld 
ENV MYSQL_LOG_DIR=/var/log/mysql

RUN mkdir -p $APACHE_RUN_DIR
RUN mkdir -p $APACHE_LOCK_DIR
RUN mkdir -p $APACHE_LOG_DIR

# Configuro phpMyAdmin
RUN \
sudo ln -s /etc/phpmyadmin/apache.conf /etc/apache2/conf-available/phpmyadmin.conf && \
sudo a2enconf phpmyadmin.conf && \
sed -i "s/dbc_dbpass/#dbc_dbpass/g" /etc/dbconfig-common/phpmyadmin.conf && \
sed -i "\$adbc_dbpass='${phpmyadmin_pass}'" /etc/dbconfig-common/phpmyadmin.conf && \
rm /etc/phpmyadmin/config.inc.php && \
rm /usr/share/phpmyadmin/libraries/plugin_interface.lib.php && \
rm /etc/phpmyadmin/config-db.php
ADD /Risorse/config.inc.php /etc/phpmyadmin/config.inc.php
ADD /Risorse/plugin_interface.lib.php /usr/share/phpmyadmin/libraries/plugin_interface.lib.php
ADD /Risorse/config-db.php /etc/phpmyadmin/config-db.php
RUN sed -i "s/password/${phpmyadmin_pass}/g" /etc/phpmyadmin/config-db.php

# Carico impostazioni phpmyadmin
RUN rm /usr/share/phpmyadmin/libraries/sql.lib.php
ADD /Risorse/sql.lib.php /usr/share/phpmyadmin/libraries/sql.lib.php

# Impostazioni preliminari MariaDB
RUN \
service mysql start && \
mysql -e "CREATE DATABASE wordpress_db;" && \
mysql -e "CREATE DATABASE phpmyadmin;" && \
mysql -e "CREATE USER 'wp_user'@'localhost' IDENTIFIED BY '${wp_password}';" && \
mysql -e "CREATE USER 'wp_user'@'%' IDENTIFIED BY '${wp_password}';" && \
mysql -e "CREATE USER 'phpmyadmin'@'localhost' IDENTIFIED BY '${phpmyadmin_pass}';" && \
mysql -e "CREATE USER 'phpmyadmin'@'%' IDENTIFIED BY '${phpmyadmin_pass}';" && \
mysql -e "GRANT ALL PRIVILEGES ON phpmyadmin.* TO 'phpmyadmin'@'localhost' IDENTIFIED BY '${phpmyadmin_pass}' WITH GRANT OPTION;" && \
mysql -e "GRANT ALL PRIVILEGES ON phpmyadmin.* TO 'phpmyadmin'@'%' IDENTIFIED BY '${phpmyadmin_pass}' WITH GRANT OPTION;" && \
mysql -e "GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wp_user'@'localhost' IDENTIFIED BY '${wp_password}' WITH GRANT OPTION;" && \
mysql -e "GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wp_user'@'%' IDENTIFIED BY '${wp_password}' WITH GRANT OPTION;" && \
mysql -e "CREATE USER 'root'@'%' IDENTIFIED BY '${root_password}';" && \
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${root_password}' WITH GRANT OPTION;" && \
mysql -e "FLUSH PRIVILEGES;" && \
mysql -e "GRANT ALL PRIVILEGES ON *.* TO root@localhost IDENTIFIED BY '${root_password}' WITH GRANT OPTION;"
RUN service mysql restart

# Scarico Wordpress, lo estraggo e lo sposto in /var/www/html
ADD https://wordpress.org/latest.tar.gz /wordpress.tar.gz
RUN tar xvzf /wordpress.tar.gz
RUN rm /wordpress.tar.gz
RUN mv /wordpress/* /var/www/html/
RUN chown -R www-data:www-data /var/www/
RUN mkdir /var/log/supervisor/

# Modifico e rinomino wp-config-sample.php per configurare correttamente wordpress e connettersi al database
RUN \
sed -i 's/database_name_here/wordpress_db/g' /var/www/html/wp-config-sample.php && \
sed -i 's/username_here/wp_user/g' /var/www/html/wp-config-sample.php && \
sed -i "s/password_here/${wp_password}/g" /var/www/html/wp-config-sample.php && \
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php 

# Espongo le porte
EXPOSE 80
EXPOSE 3306

# Carico lo script per avviare i servizi all'avvio del container
ADD /Risorse/servicestart.sh /start.sh
RUN chmod 0755 /start.sh
ENTRYPOINT ["bash", "start.sh"]

# Imposto volume
VOLUME /data_server