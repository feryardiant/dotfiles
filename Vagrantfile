# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "ubuntu/xenial64"

  config.vm.define "my-dotfile"
  config.vm.hostname = "my-dotfile"
  config.vm.provider "virtualbox" do |vb|
    # vb.gui = true
    vb.name = "vagrant-dotfile"
    vb.memory = "1024"
    vb.cpus = 2
  end

  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end
