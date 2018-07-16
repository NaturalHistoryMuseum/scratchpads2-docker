#!/bin/bash
FIRST_RUN="/FIRST_RUN"

function file_set {
  KEY_REGEX="^#\?\s*$1"
  if grep -qi "$KEY_REGEX" $3
  then
    sed -i "s/$KEY_REGEX\s*=\s*.*$/$1=$2/i" $3
  else
    echo "$1=$2" >> $3
  fi
}

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
  file_set Mailhub "$SMTP_MAILHUB" /etc/ssmtp/ssmtp.conf
  file_set FromLineOverride YES /etc/ssmtp/ssmtp.conf
  file_set hostname "$SERVER_NAME" /etc/ssmtp/ssmtp.conf

  file_set AuthUser "$MAIL_USER" /etc/ssmtp/ssmtp.conf
  file_set AuthPass "$MAIL_PASSWORD" /etc/ssmtp/ssmtp.conf
  file_set AuthMethod LOGIN /etc/ssmtp/ssmtp.conf
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