#! /bin/bash

# Builds docker run commands based on the config in sp2.yml
# Allows execution of container network without creating a stack

source bash-yaml.sh
create_variables sp2.yml

for name in $( echo ${!services_*} | tr ' ' '\n' | cut -d '_' -f 2 | uniq ); do
  image=$( eval "echo \${services_${name}_image}" )
  networks=$( eval "echo \${services_${name}_networks}" )
  ports=$( eval "echo \${services_${name}_ports}" )
  volumes=$( eval "echo \${services_${name}_volumes[*]}" )
  env_vars=$( eval "echo \${!services_${name}_environment_*} | tr ' ' '\n' | cut -d '_' -f4-" )

  cmd="docker run --name=$name --network=$networks -p$ports"

  for v in $volumes; do
    # Replace initial . with "$(pwd)"
    cmd+=" -v $(echo $v | sed -e 's/^\./"$(pwd)"/g')"
  done

  for var in $env_vars; do
    value=$( eval "echo \${services_${name}_environment_$var}" )
    cmd+=" -e $var=$value"
  done

  cmd+=" $image &"

  echo $cmd
done