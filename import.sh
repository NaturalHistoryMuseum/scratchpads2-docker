#!/usr/bin/env bash

while getopts "d:s:n:" arg; do
  case $arg in
    d)
      database=$OPTARG
      ;;
    s)
      site_files=$OPTARG
      ;;
    n)
      site_name=$OPTARG
      ;;
    esac
done

if [ -z "$site_name" ]; then
  site_name=$(basename $site_files)
fi

# Set $1 to the next unparsed option
shift $(expr $OPTIND - 1 )

echo "IMPORT_DB=$database" > .env
echo "IMPORT_FILES=$site_files" >> .env
echo "SITE_NAME=$site_name" >> .env
echo "PLATFORM_FILES=$1" >> .env
echo "COMPOSE_PROJECT_NAME=$site_name" >> .env

echo "<VirtualHost *>" > docroot.conf
echo "  DocumentRoot \"/app/sites/$site_name\"" >> docroot.conf
echo "</VirtualHost>" >> docroot.conf

echo "version: '3.1'

services:
  apache:
    volumes:" > docker-compose.override.yml

if [ -n "$1" ]; then
  echo "      - \${PLATFORM_FILES}:/app" >> docker-compose.override.yml
fi

if [ -n "$site_files" ]; then
  echo "      - \${IMPORT_FILES}:/app/sites/\${SITE_NAME}" >> docker-compose.override.yml
  echo "      - ./docroot.conf:/etc/apache2/conf-enabled/docroot.conf" >> docker-compose.override.yml
fi

echo "
  db:
    volumes:" >> docker-compose.override.yml

if [ -n "$database" ]; then
  echo "      - \${IMPORT_DB}:/docker-entrypoint-initdb.d/1-\${SITE_NAME}.sql" >> docker-compose.override.yml
  echo "      - ./mysql/scratchpads-team.sql:/docker-entrypoint-initdb.d/2-overrides.sql" >> docker-compose.override.yml
fi

docker-compose up