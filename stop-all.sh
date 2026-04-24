#!/bin/bash
docker stop -t 0 $(docker ps -q)
