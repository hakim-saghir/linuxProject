#!/bin/bash


#echo "******* Entrez l'adresse IP de la machine de sauvegarde : "
#read target

echo "****** Adresse IP de la machine de sauvegarde :  192.168.1.27"
target="192.168.1.27"

# Archiver les fichiers
sudo tar zcvf "/var/backups/scripts.tgz" "/home/hs/Bureau/linux"

# Envoyer le fichier
scp /var/backups/scripts.tgz "save@$target:/home/save/backup2/"		


echo "******* Le fichier /var/backups/scripts.tgz a été envoyé vers save@$target"

sudo rm "/var/backups/scripts.tgz"
