sudo apt-get update -y
sudo apt-get install -y python-software-properties

sudo add-apt-repository -y ppa:brightbox/ruby-ng
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
sudo apt-get install apt-transport-https ca-certificates
sudo sh -c 'echo "deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main" > /etc/apt/sources.list.d/passenger.list'
sudo chown root: /etc/apt/sources.list.d/passenger.list
sudo chmod 600 /etc/apt/sources.list.d/passenger.list

sudo apt-get update -y

sudo apt-get install -y git vim

# install od4d.org and rss-to-turtle requirements

sudo apt-get install -y curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev nodejs

sudo apt-get remove -y ruby1.9 ruby1.9.1
sudo apt-get install -y ruby2.1 ruby2.1-dev

sudo gem install bundler

sudo apt-get install -y nginx-full passenger

sudo sed -i 's/# passenger_root/passenger_root/g' /etc/nginx/nginx.conf;
sudo sed -i 's/# passenger_ruby/passenger_ruby/g' /etc/nginx/nginx.conf;

sudo cp /vagrant/nginx-od4d-org /etc/nginx/sites-available/od4d-org
sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/od4d-org /etc/nginx/sites-enabled/od4d-org

# install semantic repository (fuseki) requirements

sudo apt-get remove -y openjdk-6-jre
sudo apt-get install -y openjdk-7-jre

# create od4d user

sudo useradd od4d

PUB_KEY=$1
if [ "$PUB_KEY" != "" ]; then
  HOME_FOLDER='/home/od4d'
  SSH_FOLDER="$HOME_FOLDER/.ssh"
  KEYS_FILE="$SSH_FOLDER/authorized_keys"
  sudo mkdir -p $SSH_FOLDER
  sudo sh -c "echo '$PUB_KEY' > $KEYS_FILE"
  sudo chown -R od4d: $HOME_FOLDER
  sudo chmod 700 $SSH_FOLDER
  sudo chmod 600 $KEYS_FILE
fi

sudo mkdir /opt/od4d-org
sudo chown od4d: /opt/od4d-org

# restart od4d.org

sudo service nginx restart
