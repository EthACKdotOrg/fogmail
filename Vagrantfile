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

$basebox = <<SCRIPT
DEBIAN_FRONTEND noninteractive
echo 'APT::Install-Recommends "0";' | sudo tee /etc/apt/apt.conf.d//50-ignore-recommends
echo 'APT::Install-Suggests "0";' | sudo tee -a /etc/apt/apt.conf.d//50-ignore-recommends
sudo apt-get update -q
sudo apt-get dist-upgrade -qy
sudo apt-get autoremove -qy
sudo apt-get autoclean
sudo apt-get install -qy wget puppet curl git-core lsb-release
SCRIPT

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ethack/basebox"
  config.vm.box_check_update = true


  config.vm.provision "shell" do |s|
    s.inline = $puppet

    # create base box
    config.vm.define "basebox", autostart: false do |node|
      config.vm.box = "deb/jessie"
      s.inline = $basebox
    end

    # create introducer
    config.vm.define "introducer" do |node|
      node.vm.hostname = 'introducer'
      node.vm.network "private_network", ip: "192.168.50.2"
      s.args = "introducer"
    end

    # create some storages
    (1..4).each do |i|
      s.args = "storage"
      config.vm.define "storage-#{i}" do |node|
        node.vm.hostname = "storage-#{i}"
        node.vm.network "private_network", ip: "192.168.50.2#{i}"
      end
    end

    # create some clients
    (1..2).each do |i|
      config.vm.define "mailserver-#{i}" do |node|
        node.vm.hostname = "mailserver-#{i}"
        node.vm.network "private_network", ip: "192.168.50.3#{i}"
        s.args = "mailserver"
      end
    end
  end
end
