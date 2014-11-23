# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = "2"

$puppet = <<SCRIPT
sudo su -c " \
cd /vagrant/puppet
export FACTER_vagrant=true
puppet apply --hiera_config ./vagrant-hiera.yaml --modulepath=./modules $1.pp --verbose --show_diff
"
SCRIPT

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ethack/basebox"
  config.vm.box_check_update = true


  config.vm.provision "shell" do |s|
    s.inline = $puppet

    # create introducer
    config.vm.define "introducer" do |node|
      node.vm.hostname = 'introducer'
      node.vm.network "private_network", ip: "192.168.50.2"
      node.vm.network :forwarded_port, guest: 22, host: 8222
      s.args = "introducer"
    end

    # create some storages
    (1..4).each do |i|
      config.vm.define "storage-#{i}" do |node|
        node.vm.hostname = "storage-#{i}"
        node.vm.network "private_network", ip: "192.168.50.2#{i}"
        node.vm.network :forwarded_port, guest: 22, host: "823#{i}"
        s.args = "storage"
      end
    end

    # create some clients
    (1..2).each do |i|
      config.vm.define "mailserver-#{i}" do |node|
        node.vm.hostname = "mailserver-#{i}"
        node.vm.network "private_network", ip: "192.168.50.3#{i}"
        node.vm.network :forwarded_port, guest: 22, host: "824#{i}"
        s.args = "mailserver"
      end
    end
  end
end
