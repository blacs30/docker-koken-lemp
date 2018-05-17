# Docker + Koken + nginx = ♥

This is a fork of the official Koken Docker image. It creates a docker image for koken with php:7.1-fpm.

You need an additional webserver for static files (e.g. nginx).

## General usage

This is an example, a nginx.conf has to be provided (or can be found in the folder mentioned at the end of this file). 

```
version: '3'

services:
  db:
    image: mariadb
    restart: always
    volumes:
      - db:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=mysql
      - MYSQL_PASSWORD=koken
      - MYSQL_DATABASE=koken
      - MYSQL_USER=koken

  app:
    image: blacs30/koken:fpm
    restart: always
    volumes:
      - koken:/var/www/html
    environment:
      - MYSQL_PASSWORD=koken
      - DATABASE_HOST=db
    depends_on:
      - db

  web:
    image: nginx
    restart: always
    ports:
      - 8080:80
    volumes:
      - koken:/var/www/html:ro
      - nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - app

  cron:
    image: blacs30/koken:fpm
    restart: always
    volumes:
      - koken:/var/www/html
    entrypoint: /cron.sh
    depends_on:
      - db

volumes:
  db:
  koken:

```

Or see the folder _separated-containers_ for the docker-compose way to use this docker image.
