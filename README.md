# Wordpress-Docker

Dockerfile basato su ubuntu (ultima versione)

### Dipendenze

- Apche2
- php 7.2
- MariaDB 10.4

## Installazione di Wordpress - phpMyAdmin - MySQL Dockerfile

### Costruire l'immagine chiamata "wordpress" e imposto le variabili delle password:
##### È possibile sostituire il nome dell'immagine cambiando "wordpress" con il nome che si desidera impostare
###### NB: Modificare il valore 'password' con la password che si desidera impostare
```docker build -t wordpress . --build-arg root_password=password --build-arg wp_password=password```


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

#### Utenti:

DB_ROOT_USER = root

DB_USER = wp_user
