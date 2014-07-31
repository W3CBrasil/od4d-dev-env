#!/usr/bin/env bash

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function create_dir {
  DIR=$1
  OWNER=$2
  PERMISSION=$3

  sudo mkdir -p $DIR
  [ "$OWNER" != "" ] && sudo chown $OWNER: $DIR
  [ "$PERMISSION" != "" ] && sudo chmod $PERMISSION $DIR
}

function run_command_as {
  RUN_AS=$1
  COMMAND=$2
  sudo su $RUN_AS -c "$COMMAND"
}

function add_new_repositories_to_apt {
  echo "Adding new apt repositories..."
  sudo apt-get update -y
  sudo apt-get install -y python-software-properties
  # Ruby repository
  sudo add-apt-repository -y ppa:brightbox/ruby-ng
  # Passanger repository
  sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
  sudo apt-get install -y apt-transport-https ca-certificates
  sudo sh -c 'echo "deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main" > /etc/apt/sources.list.d/passenger.list'
  sudo chown root: /etc/apt/sources.list.d/passenger.list
  sudo chmod 600 /etc/apt/sources.list.d/passenger.list
  # Update apt
  sudo apt-get update -y
  echo "Done adding new apt repositories."
}

function install_security_updates {
  echo "Installing security updates..."
  sudo unattended-upgrades
  echo "Done installing security updates."

}

function install_requirements {
  # git is need for deployment with capistrano
  # rails requirements build-essential, nodejs (for execjs), libsqlite3-dev
  sudo apt-get install -y git nodejs build-essential libsqlite3-dev
}

function install_ruby {
  echo "Installing ruby..."
  sudo apt-get install -y ruby2.1 ruby2.1-dev
  sudo gem install bundler
  echo "Done installing ruby."
}

function install_java {
  echo "Installing java..."
  sudo apt-get remove -y openjdk-6-jre
  sudo apt-get install -y openjdk-7-jre
  echo "Done installing java."
}

function install_web_server {
  echo "Installing nginx and passenger..."
  sudo apt-get install -y nginx-full passenger
  echo "Done installing nginx and passenger."
}

function configure_web_server {
  echo "Configuring nginx and passenger..."
  APP_ENV=$1

  sudo sed -i 's/# passenger_root/passenger_root/g' /etc/nginx/nginx.conf;
  sudo sed -i 's/# passenger_ruby/passenger_ruby/g' /etc/nginx/nginx.conf;

  sudo cp $BASE_DIR/nginx-od4d-org /etc/nginx/sites-available/od4d-org
  sudo sed -i "s/{rails-env}/$APP_ENV/g" /etc/nginx/sites-available/od4d-org

  sudo rm /etc/nginx/sites-enabled/default
  sudo ln -s /etc/nginx/sites-available/od4d-org /etc/nginx/sites-enabled/od4d-org
  echo "Done configuring nginx and passenger."
}

function restart_web_server {
  sudo service nginx restart
}

function configure_gems_dir {
  THE_USER=$1
  USER_HOME="/home/$THE_USER"

  create_dir "$USER_HOME/.gem" $THE_USER
  run_command_as $THE_USER "echo -e '"'export GEM_PATH=$GEM_PATH:$HOME/.gem\nexport PATH=$PATH:$HOME/.gem/bin'"' > $USER_HOME/.bashrc"
}

function create_user {
  THE_USER=$1

  echo "Creating user '$THE_USER'..."
  sudo useradd $THE_USER

  echo "Configuring user '$THE_USER'..."
  create_dir "/home/$THE_USER" $THE_USER
  configure_gems_dir $THE_USER
  echo "Done creating user '$THE_USER'"
}

function authorize_key {
  echo "Authorizing provided key..."
  THE_USER=$1
  REMOTE_USER_KEY=$2

  SSH_FOLDER="/home/$THE_USER/.ssh"
  create_dir $SSH_FOLDER $THE_USER "700"

  KEYS_FILE="$SSH_FOLDER/authorized_keys"
  run_command_as $THE_USER "echo '$REMOTE_USER_KEY' > $KEYS_FILE"
  run_command_as $THE_USER "chmod 600 $KEYS_FILE"
  echo "Done authorizing provided key."
}

function create_deploy_dir  {
  echo "Creating deploy directory..."
  create_dir "/opt/od4d" $1
  echo "Done creating deploy directory."
}

function create_log_dir  {
  echo "Creating log directory..."
  create_dir "/var/log/od4d" $1
  echo "Done creating log directory."
}

function verify_parameters {
  if [ -z "$APP_ENV" ]; then
    echo "Please set the app environment using the 'APP_ENV' environment variable."
    exit 1
  fi

  if [ -z "$KEY_TO_AUTHORIZE" ]; then
    echo "Plese set the public key that will be used to authorize remote access using the 'KEY_TO_AUTHORIZE' environment variable."
  fi
}

# main
echo "Configuring app server..."

OD4D_USER="od4d"
verify_parameters

add_new_repositories_to_apt
install_security_updates
install_requirements
install_java
install_ruby
install_web_server
configure_web_server $APP_ENV
create_user $OD4D_USER
authorize_key $OD4D_USER "$KEY_TO_AUTHORIZE"
create_deploy_dir $OD4D_USER
create_log_dir $OD4D_USER
restart_web_server

echo "Done configuring app server."
# end main
