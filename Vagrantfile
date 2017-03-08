# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "qsite"
  config.vm.box_url = "/Volumes/data/qsite.box"
  config.vm.network :forwarded_port, guest: 3000, host: 3000
  config.vm.network :private_network, ip: "192.168.33.16"
  config.vm.hostname = "q2016"
  config.vm.synced_folder ".", "/vagrant", :nfs => true

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", 1024]
  end

  #config.vm.provision :shell, :path => "provision/bootstrap.sh"
end
