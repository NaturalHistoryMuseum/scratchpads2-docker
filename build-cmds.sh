#! /bin/bash

# Builds docker run commands based on the config in sp2.yml
# Allows execution of container network without creating a stack

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

  # Mount sp2 dev directory if present
  if [[ -d $1 ]] && [ $image = "sp2" ]; then
    cmd+=" -v $(realpath $1):/app"
  fi

  # Flags to set env vars
  for var in $env_vars; do
    value=$( eval "echo \${services_${name}_environment_$var}" )
    cmd+=" -e $var=$value"
  done

  cmd+=" $image &"

  echo $cmd
done