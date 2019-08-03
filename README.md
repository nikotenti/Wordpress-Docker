# Wordpress-Docker

Dockerfile basato su ubuntu (ultima versione)

### Dipendenze

- Apche2
- php 7.2
- MySQL 5.7 / MariaDB 10.4

## Installazione di Wordpress - phpMyAdmin - MySQL Dockerfile

### Costruire l'immagine chiamata "wordpress":
###### È possibile sostituire il nome dell'immagine cambiando "wordpress" con il nome che si desidera impostare
```docker build -t wordpress .```


### Avviare l'immagine in un nuovo container in background chiamato "wordpress": 
###### NB: È possibile redirezionare il traffico delle porte utilizzando -p (porta host):(porta container)
```docker run -tid -p 80:80 -p 3306:3306 --name 'wordpress' wordpress```


### Interagire con la bash del container "wordpress":
###### Crea una shell connessa al container wordpress
```docker exec -ti wordpress bash```

### Accesso a Wordpress - phpMyAdmin

#### Wordpress

http://localhost/

#### phpMyAdmin

http://localhost/phpmyadmin


## Installazione di Wordpress - phpMyAdmin - MariaDB docker-compose

### Costruire e avviare l'immagine in un nuovo container in background:

```docker-compose up -d```

 
### Accesso a Wordpress - phpMyAdmin

#### Wordpress

http://localhost/

#### phpMyAdmin

http://localhost:8080/



## Credenziali di accesso al Database:

#### Utente Root:

DB_ROOT_USER = root

DB_ROOT_PASS = password

#### Utente wp_user:

DB_USER = wp_user

DB_PASS = password
