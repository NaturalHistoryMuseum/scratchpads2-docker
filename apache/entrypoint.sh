#!/bin/bash
FIRST_RUN="/FIRST_RUN"

if [ ! -e $FIRST_RUN ] ; then
  touch $FIRST_RUN;
  # Symlink settings.php to all sites
  for dir in /app/sites/
  do
    if [ "$dir" != "/app/sites/default/" ]
    then
      echo "Symlink settings to ${dir}settings.php"
      ln -s /app/sites/default/settings.php ${dir}settings.php
    fi
  done

  # Configure mail sending
  RUN echo "Mailhub=$SMTP_MAILHUB\
FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf
fi

DOCROOT=/etc/apache2/conf-enabled/docroot.conf

[ -n "$SITE_DIR" ] && echo "DocumentRoot \"/app/sites/$SITE_DIR\"" >> $DOCROOT
[ -n "$SERVER_NAME" ] && echo "ServerName $SERVER_NAME" >> $DOCROOT

# If there's no cron key env variable set, generate one and create a cron job
if ! grep -q -F 'export CRON_KEY=' /etc/apache2/envvars ; then
  echo "Generated new cron key, enabled cron"
  CRON_KEY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
  echo "export CRON_KEY=$CRON_KEY" >> /etc/apache2/envvars
  # Run cron every 3 hours
  echo "0 */3 * * * wget -O - -q -t 1 $BASE_URL/cron.php?cron_key=$CRON_KEY" > /etc/cron.d/drupal
fi
cron -f &
apache2-foreground