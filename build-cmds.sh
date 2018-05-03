#! /bin/bash

# Builds docker run commands based on the config in sp2.yml
# Allows execution of container network without creating a stack

while getopts "d:s:" arg; do
  case $arg in
    d)
      database=$OPTARG
      ;;
    s)
      site_files=$OPTARG
      ;;
    esac
done

# Set $1 to the next unparsed option
shift $(expr $OPTIND - 1 )

source bash-yaml.sh
create_variables sp2.yml

# List all variables starting with `services_`, separated by newline,
# get the 2nd part when split by underscore, deduplicated
services=$( echo ${!services_*} | tr ' ' '\n' | cut -d '_' -f 2 | uniq )

for name in $services; do
  image=$( eval "echo \${services_${name}_image}" )
  networks=$( eval "echo \${services_${name}_networks}" )
  ports=$( eval "echo \${services_${name}_ports}" )
  volumes=$( eval "echo \${services_${name}_volumes[*]}" )
  env_vars=$( eval "echo \${!services_${name}_environment_*} | tr ' ' '\n' | cut -d '_' -f4-" )

  cmd="docker run --name=$name --network=$networks -p$ports"

  # Add flags to mount volumes
  for v in $volumes; do
    # Replace initial . with "$(pwd)"
    cmd+=" -v $(echo $v | sed -e 's/^\./"$(pwd)"/g')"
  done

  if [ $image = "sp2" ]; then
    # Mount sp2 dev directory if present
    if [[ -d $1 ]]; then
      cmd+=" -v $(realpath $1):/app"
    fi

    if [[ -d $site_files ]]; then
      # TODO: Instead of linking this twice, find a way to change
      # the DocumentRoot to $(basename $site_files).
      cmd+=" -v $(realpath $site_files):/app/sites/default"
      cmd+=" -v $(realpath $site_files):/app/sites/$(basename $site_files)"
    fi
  fi

  if [ $image = "mysql:5.6" ] && [[ -f $database ]]; then
    #cmd+=" -v $(basename $database .sql):/var/lib/mysql"
    cmd+=" -v $(realpath $database):/docker-entrypoint-initdb.d/1-$(basename $database)"
    cmd+=" -v $(realpath ./mysql/scratchpads-team.sql):/docker-entrypoint-initdb.d/2-sp.sql"
  fi

  # Flags to set env vars
  for var in $env_vars; do
    value=$( eval "echo \${services_${name}_environment_$var}" )
    cmd+=" -e $var=$value"
  done

  cmd+=" $image &"

  echo $cmd
done