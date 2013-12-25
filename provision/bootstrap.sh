#!/usr/bin/env bash

# check to see if we've already been provisioned
if [ -e "/etc/vagrant-provisioned" ]
then
    echo "VM already provisioned. Skipping provisioning."
    exit 0
fi

set -e # Exit script immediately on first error.

# update package lists
sudo aptitude -y update

# mysql (root password: 'pass1234')
echo "mysql-server-5.5 mysql-server/root_password password pass1234" | sudo debconf-set-selections
echo "mysql-server-5.5 mysql-server/root_password_again password pass1234" | sudo debconf-set-selections
echo "mysql-server-5.5{a} mysql-server/root_password password pass1234" | sudo debconf-set-selections
echo "mysql-server-5.5{a} mysql-server/root_password_again password pass1234" | sudo debconf-set-selections
sudo aptitude -y install mysql-server mysql-client libmysqlclient-dev

# development tools
sudo aptitude -y install build-essential git-core subversion vim

# utils
sudo aptitude -y install unzip make sudo curl

# javascript support
sudo aptitude -y install libv8-dev nodejs

# setup dealydays database
mysql -u root -ppass1234 -e "create database q2014"
mysql -u root -ppass1234 -e "grant all privileges on q2014.* to q2014@localhost identified by 'q2014'"

# run secondary script which installs rvm, ruby, and rails
su -c 'bash /vagrant/provision/vagrant-bootstrap.sh' vagrant

# create a file on the vm so we know it's been provisioned already
touch /etc/vagrant-provisioned
