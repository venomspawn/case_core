# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version '>= 1.8.3'

Vagrant.configure(2) do |config|
  config.vm.define 'develop', primary: true do |dev|
    dev_ip = '192.168.33.88'
    host_port = 8095
    guest_port = 8095

    dev.vm.provider 'virtualbox' do |machine|
      machine.memory = 1024
      machine.cpus = 1
    end

    dev.vm.network 'forwarded_port', guest: guest_port, host: host_port
    dev.vm.box = 'ubuntu/trusty64'
    dev.vm.hostname = 'case-core'
    dev.vm.network 'private_network', ip: dev_ip
    dev.ssh.forward_agent = true
    dev.vm.post_up_message =
      'Machine is up and ready to development. Use `vagrant ssh` to enter.'

    dev.vm.provision :shell, keep_color: true, inline: <<-INSTALL
      echo 'StrictHostKeyChecking no' > ~/.ssh/config
      echo 'UserKnownHostsFile=/dev/null no' >> ~/.ssh/config
      sudo apt-get install git -y
    INSTALL

    dev.vm.provision :ansible_local do |ansible|
      ansible.provisioning_path = '/vagrant/cm/provisioning'
      ansible.playbook = 'main.yml'
      ansible.inventory_path = 'inventory.ini'
      ansible.verbose = true
      ansible.limit = 'local'
      ansible.galaxy_roles_path = 'roles'
      ansible.galaxy_role_file = 'requirements.yml'
    end
  end

  config.cache.scope = :box if Vagrant.has_plugin?('vagrant-cachier')
end
