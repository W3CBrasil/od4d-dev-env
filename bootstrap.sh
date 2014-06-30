#!/usr/bin/env bash

SRC_FOLDER='/vagrant/repositories'
PROJECT_FOLDER='/project'

sudo apt-get update -y
sudo apt-get install -y python-software-properties

# add apt repositor for ruby
sudo add-apt-repository -y ppa:brightbox/ruby-ng
sudo apt-get update -y

sudo apt-get install -y vim curl git

sudo ln -s $SRC_FOLDER $PROJECT_FOLDER

for project in $(find $PROJECT_FOLDER/ -maxdepth 1 -type d)
do
  [ -f "$project/bootstrap.sh" ] && "$project/bootstrap.sh"
done

# remove uneeded packages
sudo apt-get autoremove -y