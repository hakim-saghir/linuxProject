#!/bin/bash

echo "Entrez le nom de l'utilisateur de machine serveur, son adresse IP et le répertoire de sauvegarde sous ce format (utilisateur@addresseIP:RépertoireDeSauvegarde) : "
read target

for i in $(ls /var/backups/*.tgz /var/backups/*.sql)
do
	scp $i $target
	
done
