# frozen_string_literal: true

# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version '>= 1.8.3'

Vagrant.configure(2) do |config|
  config.vm.define 'develop', primary: true do |dev|
    dev_ip = '192.168.33.88'
    host_port = 8095
    guest_port = 8095

    dev.vm.provider 'virtualbox' do |machine|
      machine.memory = 2048
      machine.cpus = 1
    end

    dev.vm.box = 'vagrant-ubuntu64-postgres'
    dev.vm.box_url = 'http://builds.it.vm/files/boxes/vagrant-ubuntu64-postgres.box'

    dev.vm.network 'forwarded_port', guest: guest_port, host: host_port
    dev.vm.hostname = 'case-core'
    dev.vm.network 'private_network', ip: dev_ip
    dev.ssh.forward_agent = true
    dev.vm.post_up_message =
      'Machine is up and ready to development. Use `vagrant ssh` to enter.'

    dev.vm.provision :shell, keep_color: true, inline: <<-INSTALL
      echo 'StrictHostKeyChecking no' > ~/.ssh/config
      echo 'UserKnownHostsFile=/dev/null no' >> ~/.ssh/config
    INSTALL

    dev.vm.provision :ansible_local do |ansible|
      ansible.provisioning_path = '/vagrant/cm/provisioning'
      ansible.playbook = 'main.yml'
      ansible.inventory_path = 'inventory.ini'
      ansible.verbose = true
      ansible.limit = 'local'
    end
  end
end
