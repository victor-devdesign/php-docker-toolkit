#!/bin/bash
docker stop -t 0 $(docker ps -f name=php8 -f name=php7 -f name=php5 -q)
