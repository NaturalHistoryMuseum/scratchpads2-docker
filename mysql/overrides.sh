#!/bin/bash
FIRST_RUN="/FIRST_RUN"
# Use omega char so the overrides get executed after Z files
OVERRIDES="/docker-entrypoint-initdb.d/Ω-overrides.sql"

if [ ! -e $FIRST_RUN ] ; then
  echo "First run"
  touch $FIRST_RUN;

  files=$(shopt -s nullglob dotglob; echo /docker-entrypoint-initdb.d/*)

  if (( ${#files} ))
  then
    echo "Setting overrides"
    echo "DELETE FROM variable WHERE name='cron_key';" >> $OVERRIDES
    echo "UPDATE apachesolr_environment SET url='http://$SOLR_HOSTNAME:8983/solr/$SOLR_CORE' WHERE env_id='solr';" >> $OVERRIDES;

    if [ "$UNSAFE_PASSWORD" != "" ]
    then
      echo "Setting unsafe password for Scratchpad Team user"
      echo "UPDATE users SET pass='\$S\$DlKfHKC6iOAoj3QnqVR0y7oOLFDfiz213nPQdeCNWqB8XuSrJPFk', status=1 WHERE uid=1;" >> $OVERRIDES;
    fi

    # if remove_modules
    echo $REMOVE_MODULES;
    IFS=';' read -r -a modules_remove <<< "$REMOVE_MODULES"
    for module in "${modules_remove[@]}"
    do
      echo $module;
      echo "UPDATE system SET status=0 WHERE name=TRIM('$module');" >> $OVERRIDES;
    done
    echo "DELETE FROM cache_bootstrap WHERE cid='systemlist';" >> $OVERRIDES;
  fi
else
  echo "Skipping setup"
fi

exec "docker-entrypoint.sh" "mysqld"
