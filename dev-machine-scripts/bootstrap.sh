#!/usr/bin/env bash

SRC_FOLDER='/vagrant/repositories'
PROJECT_FOLDER='/project'

sudo apt-get update -y
sudo apt-get install -y python-software-properties

# add apt repositor for ruby
sudo add-apt-repository -y ppa:brightbox/ruby-ng
sudo apt-get update -y

sudo apt-get install -y vim curl git libpq-dev

sudo ln -s $SRC_FOLDER $PROJECT_FOLDER

echo "========================= POSTGRESQL ==============================="
sudo /vagrant/dev-machine-scripts/postgresql.sh
sudo apt-get install -y libpq-dev
echo "========================= POSTGRESQL ==============================="

# Configures Bundler with the proper path to the PG_CONFIG file (PostgreSQL)
bundle config build.pg --with-pg-config=/usr/bin/pg_config

for project in $(find $PROJECT_FOLDER/ -maxdepth 1 -type d)
do
  [ -f "$project/bootstrap.sh" ] && "$project/bootstrap.sh"
done

# remove uneeded packages
sudo apt-get autoremove -y

# make sure we don't ask confirmation to deploy localy
echo -e "\nHost app-server.dev\n\tUserKnownHostsFile /dev/null\n\tStrictHostKeyChecking no" > $HOME/.ssh/config
