# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu-trusty-64"
  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"

  #configure ssh forward agent
  `key_file=~/.ssh/id_rsa && [[ -z $(ssh-add -L | grep $key_file) ]] && ssh-add $key_file`
  config.ssh.forward_agent = true

  config.vm.define :dev_env do |node|
    node.vm.network "private_network", ip: "10.0.0.2"

    #forward port for rails
    config.vm.network :forwarded_port, host: 3000, guest: 3000

    node.vm.provision :shell, :path => "bootstrap.sh", privileged: false

    node.vm.provider "virtualbox" do |vb|
      vb.name = "od4d-dev-env"
    end
  end

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end
end
