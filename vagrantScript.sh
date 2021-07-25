#!/bin/bash


curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install vagrant

ubuntu_box='ubuntu/trusty64'
# m2_ip=$(hostname -I)
M="M1.clone"
hostname=$HOSTNAME


echo "Vagrant.configure("2") do |config|" > VagrantFile
echo " config.vm.box = '${ubuntu_box}'" >> VagrantFile
# echo " config.vm.synced_folder \"/var/backups/\", \"/home/vagrant\", type: 'rsync'," >> VagrantFile
# echo "   rsync__exclude: '.git/'," >> VagrantFile
# echo "   rsync__args: [\"--verbose\", \"--rsync-path='sudo rsync'\", \"--archive\", \"--delete\", \"-z\"]" >> VagrantFile
echo " config.vm.hostname = '${hostname}'" >> VagrantFile
# echo " config.vm.network \"private_network\", ip: \"127.0.2.4\"" >> VagrantFile
# echo " config.vm.provision 'shell', path: 'http://m2_ip/transferArchivesAndDataBaseToMachine2.sh'" >> VagrantFile
echo " config.vm.provision 'shell', path: './Scripts/transferArchivesAndDataBaseToMachine2.sh'" >> VagrantFile

echo " config.vm.provider :virtualbox do |v|" >> VagrantFile
echo "  v.name = '${M}'" >> VagrantFile
echo "  v.gui = true" >> VagrantFile
echo " end" >> VagrantFile
echo end >> VagrantFile



