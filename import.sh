#!/usr/bin/env bash
COMPOSE_VERSION=3.5

while getopts "d:s:n:rD:p:-:" arg; do
  # Parse longform -- options
  if [ "$arg" == "-" ]; then
    read -r arg OPTARG <<< $(echo ${OPTARG//=/ })
    if [ -z "$OPTARG" ] && [[ "${!OPTIND}" != -* ]]; then
      OPTARG=${!OPTIND}
      OPTIND=$((OPTIND+1))
    fi
  fi

  case $arg in
    "?")
      # Unrecognised getopts option
      exit 1
      ;;
    d)
      database=$OPTARG
      ;;
    s)
      site_files=$(realpath $OPTARG)
      site_name=$(basename $site_files)
      if [ ! -d "$site_files" ]; then
        echo "Directory $site_files does not exist" 1>&2
        exit 1
      fi
      ;;
    n)
      project_name=$OPTARG
      ;;
    r|reset-password)
      team_password=1
      ;;
    D|domain)
      url=$OPTARG
      ;;
    p|port)
      port=$OPTARG
      ;;
    *)
      # Unrecognised longform option
      echo "$0: illegal option -- $arg" 1>&2
      exit 1
    esac
done

if [ -z "$project_name" ] && [ -n "$site_name" ]; then
  project_name=$site_name
fi

platform_files=${@:$OPTIND:1}

if [ -n "$platform_files" ]; then
  platform_files=$(realpath $platform_files)
fi

if { [ -n "$project_name" ] && ! grep -Fxqs "COMPOSE_PROJECT_NAME=$project_name" .env ; } || { [ -z "$project_name" ] && [ -e .env ]; } ; then
  # Remove unused networks so docker doesn't complain about gateway clash
  docker network prune -f
fi

# DOT ENV

[ -e .env ] && rm .env

if [ -n "$project_name" ]; then
  echo "COMPOSE_PROJECT_NAME=$project_name" >> .env
fi


if [ -n "$port" ]; then
  echo "PORT=$port" >> .env
fi

# DOCROOT CONF

[ -e docroot.conf ] && rm docroot.conf

[ -n "$site_name" ] && echo "DocumentRoot \"/app/sites/$site_name\"" >> docroot.conf

[ -n "$url" ] && echo "ServerName $url" >> docroot.conf

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


# DOCKER-COMPOSE OVERRIDE
[ -e docker-compose.override.yml ] && rm docker-compose.override.yml

vols=$((${#db_volumes[@]} + ${#apache_volumes[@]}))

if [ $vols -gt 0 ] || [ -n "$url" ]; then
  echo "version: '$COMPOSE_VERSION'

services:" > docker-compose.override.yml
fi

if [ ${#apache_volumes[@]} -gt 0 ] || [ -n "$url" ]; then
  echo "  apache:" >> docker-compose.override.yml
fi

if [ -n "$url" ]; then
  base_url="http://$url"

  if [ -n $port ]; then
    base_url+=":$port"
  fi

  echo "    environment:
      BASE_URL: $base_url" >> docker-compose.override.yml
fi

if [ ${#apache_volumes[@]} -gt 0 ]; then
  echo "    volumes:" >> docker-compose.override.yml

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