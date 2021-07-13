# Instructions du projet linux

# Rédigé par Hakim SAGHIR et Mohamed EL MATROR

# Parcours du fichier /etc/passwd et archivage des répertoires de travail des utilisateurs :

# Script 1 : getXmlAndRepositoriesOfUsers.sh

# Parcourir les utilisateurs actifs de la machine dans "/etc/passwd", archiver et sauvegarder le repertoire de travail de chaque utilisateur et générer un fichier "xml" contenant les informations suivantes de chaque utilisateur :
	- nom
	- uid
	- gid
	- home
	- shell
	- taille du répertoire de travail
	- fingerprint

# Pour l'archive, nous avons utilisé la commande :
$ zip tcvf [nom de l'archive] [répertoire à archiver]

# Pour la taille du répertoire de travail de chaque utilisateur, nous avons utilisé la commande :
$ du -s [répertoire de travail] | cut -f1
(cut -f pour récupèrer juste la taille)

# Pour le fingerprint, bous avons utilisé la commande "md5sum [nom de l'archive] | cut -d" " -f1"

*********************************************************************************************
# Installation de MySql :

# Installer mysql-server :
sudo apt-get install mysql-server

# Dans ubuntu (changer les droits pour le chargement des fichiers côté client et côté serveur), il faut ajouter dans le fichier "/etc/mysql/mysql.conf.d/mysqld.cnf"
	et faire
	$ sudo mysql
	$ set global local_infile=1;

[client]
local_infile = 1

# Rentrer su mysql
sudo mysql

# Charger un fichier sur mysql pour créer une base de donnée
$ mysql < [baseUtilisateurs.sql]
( Le fichier contient le script de création de base de données des utilisateurs "users_db", de sa table "user_tb" et le nom du fichier XML à charger dans la table )


# Créer une sauvegarde de la base de données des utilisateurs avec la commande suivante :
$ mysqldump users_db > sauvegarde_db.sql

*********************************************************************************************
# Installation de SSH sur les deux machines

# Installation de openssh-server et openssh-client
Sur la machine serveur :
						$ sudo apt-get install openssh-server

Sur la machine client :
						$ sudo apt-get install openssh-client

*********************************************************************************************
# Connexion à la machine 2 (serveur) :

# Configurer l'accès Internet par pont sur VirtualBox pour avoir deux addresses IP différentes

# Génerer une clé RSA publique dans la machine 1 :
$ ssh-keygen -t rsa

# copier la clé publique (depuis le fichier ~/.ssh/id_rsa.pub) de la machine 1 vers la machine 2 (serveur) :
$ ssh-copy-id save@srv


# Copier la sauvegarde la base de données sur la machine 2 (serveur) :
$ scp [fichiers à envoyer] [nom de l'utilisateur]@[adresse IP]:[répertoire de sauvegarde et nom du fichier]

***********************************************************************************************
# Création de la base de données des utilisateurs sur la machine 2 : 

# Creation de la base sur la machine serveur et chargement des tables à l'interieur :
$ sudo mysqladmin create users_db
$ sudo mysql users_db < save.sql

# Tester si les tables sont chargées :
$ sudo mysql
$ use users_db
$ show tables 
$ select * from user_tb

***********************************************************************************************
# Création d'utilisateur :
$ sudo adduser [nom de l'utilisateur]

# Changer d'utilisateur :
su [nom de l'utilisateur]

***********************************************************************************************
# Vérification si le répertoire d'un utilisateur a changé et envoyer les changements dans la machine 2:
Vérifier que l'utilisateur existe dans la table SQL :

	- S'il existe : - Si aucune modification n'a été trouvée sur le compte, on supprime la nouvelle archive générée.
					- Si nonn calculer la taille du répertoire de travail, Génerer une archive de son répertoire de travail et génerer le fingerprint.
	
	- Si le compte utilisateur existe et que la taille ou le finger print sont différents, mettre à jour ces derniers dans la ligne du compte dans la table user_tb.

	- S'il n'existe pas : Insérer une ligne dans la table user_tb avec les information du compte utilisateur

Appeler le script transferArchivesAndDataBaseToM2.sh pour envoyer les archive et la sauvegarde de la base de données vers la machine 2 (serveur).