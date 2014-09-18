#!/usr/bin/env bash

ROOT_FOLDER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPOSITORIES_FOLDER="$ROOT_FOLDER/repositories"

[ ! -e "$REPOSITORIES_FOLDER" ] && mkdir $REPOSITORIES_FOLDER

echo "Downloading missing repositories..."

pushd $REPOSITORIES_FOLDER &> /dev/null

if [ ! -e "$REPOSITORIES_FOLDER/OD4D" ]; then
  git clone git@github.com:W3CBrasil/OD4D
fi

if [ ! -e "$REPOSITORIES_FOLDER/od4d.org" ]; then
  git clone git@github.com:W3CBrasil/od4d.org.git
fi

if [ ! -e "$REPOSITORIES_FOLDER/rss-to-turtle" ]; then
  git clone git@github.com:W3CBrasil/od4d-rss-to-turtle.git rss-to-turtle
fi

if [ ! -e "$REPOSITORIES_FOLDER/semantic-repository" ]; then
  git clone git@github.com:W3CBrasil/od4d-semantic-repository.git semantic-repository
fi

if [ ! -e "$REPOSITORIES_FOLDER/rss-to-cms" ]; then
  git clone https://github.com/W3CBrasil/od4d-rss-to-cms.git rss-to-cms
fi

popd &> /dev/null

echo "Done dowloading repositories."

echo "Installing required vagrant plugins..."

vagrant plugin install vagrant-cachier
vagrant plugin install vagrant-hostmanager
vagrant plugin install copy_my_conf

echo "Vagrant plugins installed."

echo "Starting development environment..."

vagrant up

echo "Development environment ready."

echo "To start using the development environment use \"vagrant ssh\"."
echo "You will find all repositories under the \"/project\" directory."
