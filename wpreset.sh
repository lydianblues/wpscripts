#!/bin/bash
# Execute this script from the niroga directory only. !!!

REV=70b1cf8a87bed205c1aee0ac9d818d1715f9d9df

mysqldump -u root -phar526 niroga_wp > ../backups/niroga-${REV}.sql

exit 0

mysqladmin -u root -phar526 -f drop niroga_wp
mysqladmin -u root -phar526 create  niroga_wp
mysql -u root -phar526 niroga_wp < ../backups/niroga-${REV}.sql
sudo -u daemon git reset --hard ${REV}

# remove untracked files and directories
sudo -u daemon git clean -d -f

# put the link to reset back
sudo -u daemon ln -s ../wpscripts/wpreset.sh reset

