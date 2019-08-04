# Basato su ubuntu: ultima versione
FROM ubuntu:latest

MAINTAINER Nicholas Tenti <nikotenti@outlook.it>

# Aggiorno le repository ed il sistema
RUN apt-get update && \
    apt-get -y upgrade
    
# Installo le dipendenze
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install sudo curl systemd apache2 apache2-utils mariadb-server php libapache2-mod-php php-mysql php-curl php-gd php-xml php-mbstring  php-xmlrpc php-zip php-soap php-intl phpmyadmin

# Creo directory volume
RUN mkdir /wordpress_data

# Imposto variabili password
ARG root_password
ARG wp_password

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
sed -i 's/password_here/password/g' /var/www/html/wp-config-sample.php && \
mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php 

# Creo il database, le credenziali di accesso "root" e "wp_user" con privilegi massimi
RUN \
service mysql start && \
mysql -u root -h localhost -e "CREATE DATABASE wordpress_db;" && \
mysql -u root -h localhost -e "CREATE USER 'wp_user'@'%' IDENTIFIED BY '${wp_password}';" && \
mysql -u root -h localhost -e "GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wp_user'@'%';" && \
mysql -u root -h localhost -e "CREATE USER 'root'@'%' IDENTIFIED BY '${root_password}';" && \
mysql -u root -h localhost -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';" && \
mysql -u root -h localhost -e "FLUSH PRIVILEGES;"  && \
usermod -d /var/lib/mysql/ mysql

# Configuro phpMyAdmin
RUN \
sudo ln -s /etc/phpmyadmin/apache.conf /etc/apache2/conf-available/phpmyadmin.conf && \
sudo a2enconf phpmyadmin.conf

# Imposto l'accesso al database da remoto
RUN sed -i "$ a skip-grant-tables" /etc/mysql/mariadb.cnf

# Aggiungo uno script che consente l'esecuzione automatica dei servizi all'avvio del container
ADD servicestart.sh /start.sh
RUN chmod 0755 /start.sh
ENTRYPOINT ["bash", "start.sh"]

# Espongo le porte dei servizi
EXPOSE 80
EXPOSE 3306

# Imposto volume
VOLUME /wordpress_data
