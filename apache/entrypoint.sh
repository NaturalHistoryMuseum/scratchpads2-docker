#!/bin/bash

if ! grep -q -F 'export CRON_KEY=' /etc/apache2/envvars ; then
  CRON_KEY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
  echo "export CRON_KEY=$CRON_KEY" >> /etc/apache2/envvars
  # Run cron every 3 hours
  echo "0 */3 * * * wget -O - -q -t 1 $BASE_URL/cron.php?cron_key=$CRON_KEY" > /etc/cron.d/drupal
fi
cron -f &
apache2-foreground