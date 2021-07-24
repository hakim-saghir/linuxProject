#!/bin/bash

ubuntu_box='ubuntu/trusty64'
m2_ip=$(hostname -I)
M="M1.clone"
hostname="foo"

echo "Vagrant.configure("2") do |config|" > VagrantFile
echo " config.vm.box = '${ubuntu_box}'" >> VagrantFile

echo " config.vm.hostname = '${hostname}'" >> VagrantFile
echo " config.vm.provision 'shell', path: 'http://${m2_ip}/transferArchivesAndDataBaseToMachine2.sh'" >> VagrantFile
echo " config.vm.provider :virtualbox do |vb|" >> VagrantFile
echo "  vb.name = '${M}'" >> VagrantFile
echo " end" >> VagrantFile
echo end >> VagrantFile

vagrant up



