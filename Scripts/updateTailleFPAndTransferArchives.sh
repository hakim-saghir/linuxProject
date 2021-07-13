#!/bin/bash

# Affichage des statuts à la fin
retour=""

# Nettoyage des fichiers dans /var/backups/
rm /var/backups/*.tgz
rm /var/backups/*.sql

for i in $(cut -d: -f1,3,4,6,7 /etc/passwd)
do
	echo $i > /tmp/ligne.txt

	shell=$(cut -d: -f5 /tmp/ligne.txt)

	if [ $shell == "/bin/bash" ]
	then
		name=$(cut -d: -f1 /tmp/ligne.txt)
		uid=$(cut -d: -f2 /tmp/ligne.txt)
		gid=$(cut -d: -f3 /tmp/ligne.txt)
		home=$(cut -d: -f4 /tmp/ligne.txt)
		taille=$(du -s $home | cut -f1)

		selectedValues=$(mysql users_db -N -B -e "SELECT taille, fingerprint FROM user_tb WHERE uid = $uid")

		echo $selectedValues > /tmp/ligne.txt

		# Sauvegarder le nom de l'archive et le créer
		archiveName="/var/backups/$name.$(date +%m-%d-%y).$(date +%H-%M).tgz"
		tar zcf $archiveName --absolute-names $home

		# Génerer le fingerprint de l'archive
		fingerprint=$(md5sum $archiveName | cut -d" " -f1)

		if [ -z "$selectedValues" ]
		then
			retour="$retour\nUser: $name	|	taille: $taille	|	fingerprint: $fingerprint	[INSERTION]"
			mysql users_db -e "INSERT INTO user_tb VALUES(0,'$name', $uid, $gid, '$home', '$shell', $taille, '$fingerprint')"
		else
			old_taille=$(cut -d" " -f1 /tmp/ligne.txt)
			old_fingerprint=$(cut -d" " -f2 /tmp/ligne.txt)

			if [ "$taille" != "$old_taille" ]  || [ "$fingerprint" != "$old_fingerprint" ];
			then
				retour="$retour\nUser: $name	|	taille: $taille	|	fingerprint: $fingerprint	[UPDATE]"
				mysql users_db -e "UPDATE user_tb SET taille = $taille, fingerprint = '$fingerprint' WHERE uid = $uid"
			else
				retour="$retour\nUser: $name	|	taille: $taille	|	fingerprint: $fingerprint	[NO CHANGE]"
			fi
		fi
	fi
done

echo -e $retour
