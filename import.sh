#!/usr/bin/env bash

while getopts "d:s:n:p" arg; do
  case $arg in
    d)
      database=$OPTARG
      ;;
    s)
      site_files=$(realpath $OPTARG)
      if [ ! -d "$site_files" ]; then
        echo "Directory $site_files does not exist" 1>&2
        exit 1
      fi
      ;;
    n)
      site_name=$OPTARG
      ;;
    p)
      team_password=1
      ;;
    esac
done

if [ -z "$site_name" ] && [ -n "$site_files" ]; then
  site_name=$(basename $site_files)
fi

platform_files=${@:$OPTIND:1}

if [ -n "$platform_files" ]; then
  platform_files=$(realpath $platform_files)
fi

[ -e .env ] && rm .env
[ -e docroot.conf ] && rm docroot.conf

if [ -n "$site_name" ]; then
  echo "COMPOSE_PROJECT_NAME=$site_name" >> .env

  echo "<VirtualHost *>" >> docroot.conf
  echo "  DocumentRoot \"/app/sites/$site_name\"" >> docroot.conf
  echo "</VirtualHost>" >> docroot.conf
fi

apache_volumes=()

if [ -n "$platform_files" ]; then
  apache_volumes+=("$platform_files:/app")
fi

if [ -n "$site_files" ]; then
  apache_volumes+=("$site_files:/app/sites/$site_name")
  apache_volumes+=("./docroot.conf:/etc/apache2/conf-enabled/docroot.conf")
fi

db_volumes=()

if [ -n "$database" ]; then
  db_volumes+=("$database:/docker-entrypoint-initdb.d/1-$site_name.sql")
  db_volumes+=("./mysql/set-solr.sql:/docker-entrypoint-initdb.d/2-overrides.sql")
fi

if [ -n "$team_password" ]; then
  db_volumes+=("./mysql/reset-password.sql:/docker-entrypoint-initdb.d/3-reset-password.sql")
fi

[ -e docker-compose.override.yml ] && rm docker-compose.override.yml

vols=(${#db_volumes[@]} + ${#apache_volumes[@]})

if [ $vols -gt 0 ]; then
  echo "version: '3.1'

services:" > docker-compose.override.yml
fi

if [ ${#apache_volumes[@]} -gt 0 ]; then
  echo "  apache:
    volumes:" >> docker-compose.override.yml

  for line in "${apache_volumes[@]}"
  do
    echo "      - $line" >> docker-compose.override.yml
  done
fi

if [ ${#db_volumes[@]} -gt 0 ]; then
  echo "  db:
    volumes:" >> docker-compose.override.yml

  for line in "${db_volumes[@]}"
  do
    echo "      - $line" >> docker-compose.override.yml
  done
fi

docker-compose up