#!/bin/bash

docker login

docker pull php:8.3-fpm-alpine

docker build -t jsantoso/php-8.3-fpm-alpine:latest .

docker push jsantoso/php-8.3-fpm-alpine:latest
