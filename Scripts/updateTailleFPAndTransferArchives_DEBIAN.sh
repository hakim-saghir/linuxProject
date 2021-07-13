#!/bin/bash

transfer=false
rm /var/backups/*.tgz /var/backups/*.sql
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
		GZIP=-n tar zcvf $archiveName $home > /tmp/archives.log

		# Génerer le fingerprint de l'archive
		fingerprint=$(md5sum $archiveName | cut -d" " -f1)

		if [ -z "$selectedValues" ]
		then
			echo "User :'$name' | taille: $taille | fingerprint: $fingerprint [INSERTION]"
			mysql users_db -e "INSERT INTO user_tb VALUES(0,'$name', $uid, $gid, '$home', '$shell', '$taille', '$fingerprint')" | transfer=true
		else
			old_taille=$(cut -d" " -f1 /tmp/ligne.txt)
			old_fingerprint=$(cut -d" " -f2 /tmp/ligne.txt)

			if [ "$taille" != "$old_taille" ]  || [ "$fingerprint" != "$old_fingerprint" ];
			then
				echo "User :'$name' | taille: $taille | fingerprint: $fingerprint [UPDATE]"
				mysql users_db -e "UPDATE user_tb SET taille = $taille, fingerprint = '$fingerprint' WHERE uid = $uid" | transfer=true
			else
				echo "User :'$name' | taille: $taille | fingerprint: $fingerprint [NO CHANGE]"
			fi
		fi
	fi
done
if $transfer; then
	mysqldump users_db > /var/backups/save_db.sql
fi	

