Docker version of Laravel Homestead

# How To build it
  1. OS ubuntu14.04
  ```
     mv Dockerfile.ubuntu Dockerfile
     docker build -t laravel-docker .
  ```
  2. OS Mac
  ```   
     mv Dockerfile.mac Dockerfile
     docker build -t laravel-docker .
  ```

laravel version 5.4

# Build Information
You can find the latest build details on the [Docker Hub](https://hub.docker.com/r/ninjia/laravel-docker/)

# What works
- [x] Nginx 1.12
- [x] PHP 7.0
- [x] SQLite
- [x] MySQL 5.5
- [x] Redis
- [x] NodeJS
- [x] Bower
- [x] Gulp
- [x] Composer
- [x] Laravel Envoy
- [x] Laravel Installer

# How to use the container
### How to find and use the image (the easy way)
  1. Search for `ninjia`
  2. docker pull ninjia/laravel-docker
  3. Point the `/var/www/html/app` volume to your local application directory.

### CLI (the other easy way)
  1. Pull in the image
  ```
    docker pull ninjia/laravel-docker
  ```  
  2. Run the container
  ```
    docker run --name laravel -d -p 8088:80 -v /path/to/your/app:/var/www/html/app ninjia/laravel-docker
  ```
  3. Stop or start container
  ```
    docker stop laravel
    docker start laravel
  ```
  4. SSH to container
  ```
    docker exec -ti laravel /bin/bash
    supervisorctl reload
    cd /var/www/html/app
  ```
# MySQL Details
ubuntu image
- MySQL Username = `homestead`
- MySQL Password = `secret`
- MySQL Database = `homestead`
