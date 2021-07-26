#!/bin/bash

echo "Entrez le nom de l'utilisateur à créer"
read userName

sudo adduser $userName

for i in $(cut -d: -f1,3,4,6,7 /etc/passwd)
do
	echo $i > /tmp/ligne.txt

	name=$(cut -d: -f1 /tmp/ligne.txt)
		
	if [ $name == $userName ]
	then	
		uid=$(cut -d: -f2 /tmp/ligne.txt)
		gid=$(cut -d: -f3 /tmp/ligne.txt)
		home=$(cut -d: -f4 /tmp/ligne.txt)
        shell=$(cut -d: -f5 /tmp/ligne.txt)
        taille=$(du -s $home | cut -f1)

		# Sauvegarder le nom de l'archive et le créer
		archiveName="/var/backups/$name.$(date +%m-%d-%y).$(date +%H-%M).tgz"
		sudo tar zcvf $archiveName $home

		# Génerer le fingerprint de l'archive
		fingerprint=$(md5sum $archiveName | cut -d" " -f1)
	fi
done


# USE users_db
sudo mysql users_db -e "INSERT INTO user_tb VALUES(0, '$userName', $uid, $gid, '$home', '$shell', $taille, '$fingerprint')"

echo "Utilisateur créé et ligne ajouté à la table users_db.user_tb."
