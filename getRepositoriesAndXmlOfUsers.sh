#!/bin/bash

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > donneesUtilisateurs.xml 
echo "<users>" >> donneesUtilisateurs.xml

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

		# Sauvegarder le nom de l'archive et le créer
		archiveName="/var/backups/$name.$(date +%m-%d-%y).$(date +%H-%M).tgz"
		tar zcvf $archiveName $home

		# Génerer le fingerprint de l'archive
		fingerprint=$(md5sum $archiveName | cut -d" " -f1)

        # Informations de l'utilisateur sous format XML
		echo "	<user>" >> donneesUtilisateurs.xml
		echo "		<name>$name</name>" >> donneesUtilisateurs.xml
		echo "		<uid>$uid</uid>" >> donneesUtilisateurs.xml
		echo "		<gid>$gid</gid>" >> donneesUtilisateurs.xml
		echo "		<home>$home</home>" >> donneesUtilisateurs.xml
		echo "		<shell>$shell</shell>" >> donneesUtilisateurs.xml
		echo "		<taille>$taille</taille>" >> donneesUtilisateurs.xml
		echo "		<fingerprint>$fingerprint</fingerprint>" >> donneesUtilisateurs.xml
		echo "	</user>" >> donneesUtilisateurs.xml
	fi
done
echo "</users>" >> donneesUtilisateurs.xml

