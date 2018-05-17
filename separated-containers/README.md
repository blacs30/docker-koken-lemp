# Docker + Koken + nginx = ♥

This is a fork of the official Koken Docker image. It runs separate containers for:
* database (MariaDb)
* webserver (Nginx)
* application (koken with php-fpm 7.1)
* cron

## Features

* Automatically sets up and configures the database for Koken and skips that step in the installation process.
* Adds a cron job to do periodic cleanup of the image cache.
* nginx/PHP configured for best Koken performance.
* Can be used on any machine with Docker installed.

## General usage

You can simply use docker-compose to start all the containers at once

1. Install [Docker](https://www.docker.io/gettingstarted/#h_installation).
2. Execute `docker-compose up` to start the containers

This forwards port 8080 on your host machine to the instance of Koken running on port 80 inside the container. You can now access your new Koken install by loading the IP address or domain name for your host in a browser. Your files reside in `/data/koken/www` on the host machine, while the MySQL data lives in `/var/lib/mysql`.
