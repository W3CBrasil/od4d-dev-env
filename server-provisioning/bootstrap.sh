#!/usr/bin/env bash

PUB_KEY=$1
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
[ "$LOGNAME" == "vagrant" ] && BASE_DIR="/vagrant"

function create_dir {
  DIR=$1
  OWNER=$2
  PERMISSION=$3

  sudo mkdir -p $DIR
  [ "$OWNER" != "" ] && sudo chown $OWNER: $DIR
  [ "$PERMISSION" != "" ] && sudo chmod $PERMISSION $DIR
}

function add_new_repositories_to_apt {
  sudo apt-get update -y
  sudo apt-get install -y python-software-properties
  # Ruby repository
  sudo add-apt-repository -y ppa:brightbox/ruby-ng
  # Passanger repository
  sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
  sudo apt-get install apt-transport-https ca-certificates
  sudo sh -c 'echo "deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main" > /etc/apt/sources.list.d/passenger.list'
  sudo chown root: /etc/apt/sources.list.d/passenger.list
  sudo chmod 600 /etc/apt/sources.list.d/passenger.list
  # Update apt
  sudo apt-get update -y
}

function install_security_updates {
  #sudo unattended-upgrades
  echo "Security updates"
}

function install_requirements {
  # git is need for deployment with capistrano
  # rails requirements nodejs (for execjs), libsqlite3-dev
  sudo apt-get install -y git nodejs libsqlite3-dev
    #curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev
}

function install_ruby {
  sudo apt-get install -y ruby2.1 ruby2.1-dev
  sudo gem install bundler
}

function install_java {
  sudo apt-get remove -y openjdk-6-jre
  sudo apt-get install -y openjdk-7-jre
}

function install_web_server {
  sudo apt-get install -y nginx-full passenger
}

function configure_web_server {
  sudo sed -i 's/# passenger_root/passenger_root/g' /etc/nginx/nginx.conf;
  sudo sed -i 's/# passenger_ruby/passenger_ruby/g' /etc/nginx/nginx.conf;

  sudo cp $BASE_DIR/nginx-od4d-org /etc/nginx/sites-available/od4d-org
  sudo rm /etc/nginx/sites-enabled/default
  sudo ln -s /etc/nginx/sites-available/od4d-org /etc/nginx/sites-enabled/od4d-org
}

function restart_web_server {
  sudo service nginx restart
}

function configure_gems_dir {
  THE_USER=$1
  THE_USER="od4d"
  USER_HOME="/home/$THE_USER"
  create_dir "$USER_HOME/.gem" $THE_USER

  sudo su $THE_USER -c "echo -e '"'export GEM_PATH=$GEM_PATH:$HOME/.gem\nexport PATH=$PATH:$HOME/.gem/bin'"' >> $USER_HOME/.bashrc"
}

function authorize_key {
  if [ "$PUB_KEY" == "" ]; then
    echo "No public key provided"
    exit 0
  fi

  THE_USER=$1

  SSH_FOLDER="/home/$THE_USER/.ssh"
  create_dir $SSH_FOLDER $THE_USER "700"

  KEYS_FILE="$SSH_FOLDER/authorized_keys"
  sudo su $THE_USER -c "echo '$PUB_KEY' > $KEYS_FILE"
  sudo su $THE_USER -c "chmod 600 $KEYS_FILE"
}

function create_user {
  THE_USER=$1
  sudo useradd $THE_USER

  create_dir "/home/$THE_USER" $THE_USER
  configure_gems_dir $THE_USER
  authorize_key $THE_USER
}

function create_deploy_dir  {
  create_dir "/opt/od4d" $1
}

function create_log_dir  {
  create_dir "/var/log/od4d" $1
}

add_new_repositories_to_apt
install_security_updates
install_requirements
install_java
install_ruby
install_web_server
configure_web_server
create_user "od4d"
create_deploy_dir "od4d"
create_log_dir "od4d"
restart_web_server
