# Wordpress-Docker

Dockerfile based on ubuntu (latest version)

### Dependences

- Apche2
- php 7.2
- MariaDB 10.4

## Wordpress Installation - phpMyAdmin - MySQL Dockerfile

### Build the image called "wordpress" and set the password variables:
##### You can replace the image name by changing "wordpress" with the name you want to set
###### ATTENTION: Change the 'password' value to the password you want to set
```docker build -t wordpress . --build-arg root_password=password --build-arg wp_password=password --build-arg phpmyadmin_pass=password```


### Run the image in a new container in the background called "wordpress": 
###### ATTENTION: You can redirect port traffic using -p (host port) :( container port)
```docker run -tid -p 80:80 -p 3306:3306 --name 'wordpress' wordpress```


### Interacting with the "wordpress" container bash:
###### Create a shell connected to the wordpress container
```docker exec -ti wordpress bash```


## Wordpress installation - phpMyAdmin - MariaDB docker-compose

### Build and launch the image in a new container in the background:

```docker-compose up -d```

 
### Access to Wordpress - phpMyAdmin

#### Wordpress

http://local-ip/

#### phpMyAdmin

http://local-ip:8080/



## Database access credentials:

#### User:

DB_ROOT_USER = root

DB_USER = wp_user

DB_USER = phpmyadmin
