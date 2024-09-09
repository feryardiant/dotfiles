# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "perk/ubuntu-2204-arm64"
  # config.vm.box = "ubuntu/xenial64"

  config.vm.define "dotfile"
  config.vm.hostname = "dotfile"
  # config.vm.synced_folder ".", "/vagrant"

  config.vm.provider "qemu" do |q|
    # q.gui = true
    q.name = "vagrant-dotfile"
    q.memory = "512"
    q.cpus = 2
  end

  config.vm.provision "shell", inline: <<-SHELL
    apt-get update -q
  SHELL
end
