#!/bin/bash

# Nettoyage des fichiers dans /var/backups/
sudo rm -f /var/backups/*.tgz

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > ../xml/donneesUtilisateurs.xml 
echo "<users>" >> ../xml/donneesUtilisateurs.xml

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

		# Archiver les données de l'utilisateur
		sudo tar zcvf "/var/backups/$name.tgz" $home

		# Génerer le fingerprint de l'archive
		fingerprint=$(md5sum "/var/backups/$name.tgz" | cut -d" " -f1)

        # Informations de l'utilisateur sous format XML
		echo "	<user>" >> ../xml/donneesUtilisateurs.xml
		echo "		<name>$name</name>" >> ../xml/donneesUtilisateurs.xml
		echo "		<uid>$uid</uid>" >> ../xml/donneesUtilisateurs.xml
		echo "		<gid>$gid</gid>" >> ../xml/donneesUtilisateurs.xml
		echo "		<home>$home</home>" >> ../xml/donneesUtilisateurs.xml
		echo "		<shell>$shell</shell>" >> ../xml/donneesUtilisateurs.xml
		echo "		<taille>$taille</taille>" >> ../xml/donneesUtilisateurs.xml
		echo "		<fingerprint>$fingerprint</fingerprint>" >> ../xml/donneesUtilisateurs.xml
		echo "	</user>" >> ../xml/donneesUtilisateurs.xml
	fi
done
echo "</users>" >> ../xml/donneesUtilisateurs.xml

# Supprimer le fichier temporaire
sudo rm tmp

echo "******* Le fichier xml a été généré."
echo "******* Les répertoires des utilisateurs ont été archivés et sauvegardés dans le répertoire /var/backups/."

