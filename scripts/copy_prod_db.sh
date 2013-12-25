#!/bin/sh
PROD=/var/rails/q2010.org
DEV=/var/rails/q2010dev.nazquizzing.org
BACKUPS=$DEV/public/backups
TIMESTAMP=`date +%Y.%m.%d.%H.%M`

mysqldump -u qsite -pqs209242  qsite_registration > $BACKUPS/qsite_registration.$TIMESTAMP.sql
mysql -u qsite -pqs209242 -e 'drop database qsite_registration_dev'
mysql -u qsite -pqs209242 -e 'create database qsite_registration_dev'
mysql -u qsite -pqs209242 qsite_registration_dev < $BACKUPS/qsite_registration.$TIMESTAMP.sql
