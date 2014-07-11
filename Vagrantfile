# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu-trusty-64"
  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"

  config.hostmanager.enabled = true
  config.hostmanager.include_offline = true

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end

  #configure ssh forward agent
  `key_file=~/.ssh/id_rsa && [[ -z $(ssh-add -L | grep $key_file) ]] && ssh-add $key_file`
  config.ssh.forward_agent = true

  config.vm.define :dev_machine, primary: true do |node|
    node.vm.hostname = "dev-machine.dev"
    node.vm.network "private_network", ip: "10.0.0.2"

    #forward port for rails
    node.vm.network :forwarded_port, host: 3000, guest: 3000

    node.vm.provision :shell, :path => "bootstrap.sh", privileged: false
    node.vm.provision :copy_my_conf do |copy_conf|
      copy_conf.git
      copy_conf.vim
    end

    node.vm.provider "virtualbox" do |vb|
      vb.name = "od4d-dev-env"
    end
  end

  config.vm.define :app_server do |node|
    node.vm.hostname = "app-server.dev"
    node.vm.network "private_network", ip: "10.0.0.3"

    node.vm.network 'forwarded_port', guest: 80, host: 10080

    id_rsa_ssh_key_pub = File.read(File.join(Dir.home, ".ssh", "id_rsa.pub"))
    node.vm.provision :shell do |s|
      s.path = "server-provisioning/bootstrap.sh"
      s.args = "\"#{id_rsa_ssh_key_pub}\""
      s.privileged = false
    end

    node.vm.provider "virtualbox" do |vb|
      vb.name = "od4d-app-server"
      vb.customize ["modifyvm", :id, "--memory", "1024"]
    end
  end

end
