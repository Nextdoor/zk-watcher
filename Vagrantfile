require './vagrant.rb'

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'ubuntu-14.04'
  config.vm.box_url = 'https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box'

  # Forward ports from the HOST machine to the GUEST VM
  config.vm.network :forwarded_port, guest: 8154, host: 8154, auto_correct: true
  config.vm.network :forwarded_port, guest: 8155, host: 8153, auto_correct: true
  config.vm.network :private_network, type: "dhcp"

  # VirtualBox Specific Customization
  config.vm.provider :virtualbox do |vb|
    vb.gui = false
    vb.customize ['modifyvm', :id, '--memory', '512']
  end
  config.nfs.map_uid = Process.uid
  config.nfs.map_gid = Process.gid
  config.vm.synced_folder './', '/home/vagrant/src', type: "nfs"

  # Required to go and get our dependencies using `godep` below
  config.vm.provision "file", source: "~/.gitconfig", destination: ".gitconfig"
  config.vm.provision "file", source: "~/.ssh/id_rsa", destination: ".ssh/id_rsa"
  config.vm.provision 'shell', inline: 'apt-get install -yf git python-virtualenv default-jre'

  # Before running Puppet, we need to install some gems.
  config.vm.provision 'shell', inline: 'curl -sSL https://get.docker.com/ | sh'
  config.vm.provision 'shell', inline: 'usermod -aG docker vagrant'
end
