#!/usr/bin/env bash

set -e # Exit script immediately on first error.

# install rvm
cd /home/vagrant
\curl -L https://get.rvm.io | bash -s stable

source /home/vagrant/.profile
source /home/vagrant/.rvm/scripts/rvm

# install ruby
rvm install 1.8.6
rvm use 1.8.6 --default

# install the bundler
#gem install bundler

# setup the environment
source /home/vagrant/.bashrc
source /home/vagrant/.bash_profile
source /home/vagrant/.profile

# downgrade rubygems
#gem update --system 1.5.3

# install rails and dependencies
gem install rails -v 2.3.5
gem install mysql -v 2.8.1
gem install RedCloth
gem install mongrel
