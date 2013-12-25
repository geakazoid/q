# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "precise64-vanilla"
  config.vm.box_url = "http://files.realnets.net/vagrant/precise64-vanilla.box"
  config.vm.network :forwarded_port, guest: 3000, host: 3000
  config.vm.network :private_network, ip: "192.168.33.11"
  config.vm.hostname = "q2014"
  config.vm.synced_folder ".", "/vagrant", :nfs => true

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", 1024]
  end

  config.vm.provision :shell, :path => "provision/bootstrap.sh"
end
