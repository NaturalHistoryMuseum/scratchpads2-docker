#!/usr/bin/env bash

docker build -t sp2 ./apache
docker build -t sp2-solr ./solr
docker build -t sp2-mysql ./mysql