#! /bin/bash

# This script is an alternative to creating a stack

# Make sure containers are built & network is created
docker build -t sp2 apache
docker build -t sp2-solr solr
docker network create sp_drupal

# Start & connect web server & mysql containers
echo
echo Starting webserver on http://localhost:8080 ...
echo

# Build docker commands and run
eval $(source ./build-cmds.sh $1)

# Shut down on interrupt
trap_stop () {
    echo
    echo "Stopping..."
    docker stop apache
    docker rm apache
    docker stop db
    docker rm db
    docker stop solr
    docker rm solr
}

trap trap_stop INT TERM

# Prevent exit until services have stopped
wait