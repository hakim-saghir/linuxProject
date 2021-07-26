#!/bin/bash

# Affichage des statuts à la fin
statut=""

# Des fichiers ont été modifiés ?
transfer=false

# Nettoyage des fichiers dans /var/backups/
sudo rm -f /var/backups/*.tgz

# Parcourir les utilisateurs dans /etc/passwd
for i in $(cut -d: -f1,3,4,6,7 /etc/passwd)
do
	echo $i > tmp

	shell=$(cut -d: -f5 tmp)

	if [ $shell == "/bin/bash" ]
	then
		name=$(cut -d: -f1 tmp)
		uid=$(cut -d: -f2 tmp)
		gid=$(cut -d: -f3 tmp)
		home=$(cut -d: -f4 tmp)
		taille=$(sudo du -s $home | cut -f1)

		selectedValues=$(sudo mysql users_db -N -B -e "SELECT taille, fingerprint FROM user_tb WHERE uid = $uid")

		echo $selectedValues > tmp

		# Archiver les données de l'utilisateur
		sudo tar zcvf "/var/backups/$name.tgz" $home

		# Génerer le fingerprint de l'archive
		fingerprint=$(md5sum "/var/backups/$name.tgz" | cut -d" " -f1)

		# Si l'utilisateur est inexistant dans la table
		if [ -z "$selectedValues" ]
		then
			statut="******* $statut\nUser: $name, taille: $taille, fingerprint: $fingerprint -> [INSERTION]"
			sudo mysql users_db -e "INSERT INTO user_tb VALUES(0,'$name', $uid, $gid, '$home', '$shell', $taille, '$fingerprint')"
			transfer=true
		
		# Sinon on vérifie si le fingerprint et la taille ont changé
		else
			old_taille=$(cut -d" " -f1 tmp)
			old_fingerprint=$(cut -d" " -f2 tmp)

			# Si la taille ou le fingerprint ont changé
			if [ "$taille" != "$old_taille" ]  || [ "$fingerprint" != "$old_fingerprint" ];
			then
				statut="******* $statut\nUser: $name, taille: $taille, fingerprint: $fingerprint -> [UPDATE]"
				sudo mysql users_db -e "UPDATE user_tb SET taille = $taille, fingerprint = '$fingerprint' WHERE uid = $uid"
				transfer=true

			# Rien n'a été modifié
			else
				statut="******* $statut\nUser: $name, taille: $taille, fingerprint: $fingerprint -> [NO CHANGE]"
				sudo rm -f "/var/backups/$name.tgz"
			fi
		fi
	fi
	
done

echo -e $statut

# Si il y'a eu des modifications dans les répertoires de travail, on transfert les repertoire modifiés
if $transfer
then
	# On fait une sauvegarde de la base de données
	echo "******* La base de données a été mise à jour."	
	sudo mysqldump users_db > /home/hs/Bureau/linux/sql/save/users_db_save.sql
	echo "******* Une sauvegarde de la base de données users_db a été crée /home/hs/Bureau/linux/sql/save/users_db_save.sql."

	
	#echo "******* Entrez l'adresse IP de la machine de sauvegarde : "
	#read target
	
	echo "****** Adresse IP de la machine de sauvegarde :  192.168.1.27"
	target="192.168.1.27"
	
	
	# Transfèrer les repertoires de travail
	for i in $(ls /var/backups/*.tgz)
	do
		echo $i
		scp $i "save@$target:/home/save/backup2/"		
		echo "******* Le fichier $i a été envoyé vers save@$target:/home/save/backup2/"
	done
	
	
	# Transfèrer la sauvegarde de la base de données
	scp "/home/hs/Bureau/linux/sql/save/users_db_save.sql" "save@$target:/home/save/backup2/"
	echo "******* Le fichier /home/hs/Bureau/linux/sql/save/users_db_save.sql a été envoyé vers save@$target:/home/save/backup2/"
fi

# Supprimer le fichier temporaire
sudo rm tmp
