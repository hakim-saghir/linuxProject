#!/bin/bash


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
		
		selectedValues=$(mysql users_db -N -B -e "SELECT taille, fingerprint FROM user_tb WHERE uid=$iud")
		exit
		echo $selectedValues > /tmp/ligne.txt
		# Sauvegarder le nom de l'archive et le créer
		archiveName="/var/backups/$name.$(date +%m-%d-%y).$(date +%H-%M).tgz"
		tar zcvf $archiveName $home

		# Génerer le fingerprint de l'archive
		fingerprint=$(md5sum $archiveName | cut -d" " -f1)
		if [ -z "$selectedValues" ]
		then
			mysqL users_db -e "INSERT INTO user_tb VALUES(0,'$name', $uid, $gid, '$home', '$shell', $taille, '$fingerprint')"
		else	
			old_taille=$(echo $selectedValues | cut -f1)
			old_fingerprint=$(echo $selectedValues | cut -f2)
			if [ $taille != $old_taille ] || [ $fingerprint != $old_fingerprint ];
			then
				mysql users_db -e "UPDATE user_tb SET taille=$taille, fingerprint=$fingerprint WHERE uid=$uid" | echo "UPDATE : user :'$name' | taille: $taille | fingerprint: $fingerprint "
			fi
		fi 
	fi
done

