<?php

$options['db_type'] = 'mysql';
$options['db_host'] = getenv('MYSQL_HOST');
$options['db_port'] = '3306';
$options['db_passwd'] = getenv('MYSQL_PASSWORD');
$options['db_name'] = getenv('MYSQL_DATABASE');
$options['db_user'] = getenv('MYSQL_USER');
$options['installed'] = true;

$_SERVER['db_type'] = $options['db_type'];
$_SERVER['db_port'] = $options['db_port'];
$_SERVER['db_host'] = $options['db_host'];
$_SERVER['db_user'] = $options['db_user'];
$_SERVER['db_passwd'] = $options['db_passwd'];
$_SERVER['db_name'] = $options['db_name'];

# Local non-aegir-generated additions.
//@include_once('/var/aegir/platforms/scratchpads-2.9.0/sites/bio.acousti.ca/local.drushrc.php');
