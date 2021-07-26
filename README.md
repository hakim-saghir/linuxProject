# Instructions du projet linux : 
**Sujet :** Gestion et description de données d'un serveur de comptes

*Rédigé par **Hakim SAGHIR** et **Mohamed EL MATROR***

## Le serveur de comptes : machine M1

 Créer 4 comptes utilisateurs sur M1
 
 Génerer le xml des utilisateurs et archiver les répertoires de travail
 
 Les fichiers xml sont sauvegardés dans le dossier xml


### Script 1 : getXmlAndRepositoriesOfUsers.sh

 Parcourir les utilisateurs actifs de la machine dans **"/etc/passwd"**, archiver et sauvegarder le repertoire de travail de chaque utilisateur et générer un fichier **xml** contenant les informations suivantes de chaque utilisateur :
 
- nom
	
- uid
	
- gid
	
- home
	
- shell
	
- taille du répertoire de travail
	
- fingerprint

#### Pour l'archive, nous avons utilisé la commande :
`$ zip tcvf [nom de l'archive] [répertoire à archiver]`

#### Pour la taille du répertoire de travail de chaque utilisateur, nous avons utilisé la commande :
`$ du -s [répertoire de travail] | cut -f1
(cut -f pour récupèrer juste la taille)`

#### Pour le fingerprint, bous avons utilisé la commande :
`md5sum [nom de l'archive] | cut -d" " -f1`

*********************************************************************************************
### Récupération des données systèmes :

#### Installation de MySql :

`sudo apt-get install mysql-server`

*Dans ubuntu (changer les droits pour le chargement des fichiers côté client et côté serveur), il faut ajouter dans le fichier **"/etc/mysql/mysql.conf.d/mysqld.cnf"**
	:*
	
	[client]
	
	local_infile = 1
	
*et la commande suivante:*

	$ sudo mysql
	$ set global local_infile=1;
	
* Ou utiliser directement cette commande *
$ sudo mysql -e "SOURCE /repertoire/fichier.sql" --local-infile=1


#### Charger un fichier sur mysql pour créer une base de donnée:

`$ mysql < [baseUtilisateurs.sql]`

*Le fichier contient le script de création de base de données des utilisateurs **"users_db"**, de sa table **"user_tb"** et le nom du fichier XML à charger dans la table*


####  Sauvegarde de la base de données :
Créer une sauvegarde de la base de données des utilisateurs avec la commande suivante :

`$ mysqldump users_db > sauvegarde_db.sql`

### Création d'une base SQL & remplissage de données :

#### Script 2 : creer_un_utilisateur_et_sa_table_dans_la_base.sh
Il s'agit d'un script permettant de créer un compte utilisateur système et de rajouter l'utilisateur dans la base users_db.

##### Script 3 : 3_mettre_ajour_la_base_de_donnees_si_changement_taille_fingerprint_et_transferer_sauvegardes_vers_m2.sh

Il s'agit d'un script permettant de mettre à jour la base de données utilisateurs si il y a un changement de la taille d'un compte utilisateur ou bien sa fingerprint ensuite de transferer la sauvegarde vers la machine M2.
#### Script 4 : transferer_les_scripts_sur_m2.sh

Ce script permet de transferer des scripts d'archives depuis M1 vers M2
*********************************************************************************************

### Sauvegarder la base de données sur la machine M2:

#### Installation de SSH sur les deux machines

Sur la machine serveur : `$ sudo apt-get install openssh-server`

Sur la machine client : `$ sudo apt-get install openssh-client`

*********************************************************************************************
#### Connexion à la machine 2 (serveur) :

Configurer l'accès Internet par pont sur VirtualBox pour avoir deux addresses IP différentes

Génerer une clé RSA publique dans la machine 1 :

`$ ssh-keygen -t rsa`

Copier la clé publique (*depuis le fichier **~/.ssh/id_rsa.pub** *) de la machine 1 vers la machine 2 (serveur) :

`$ ssh-copy-id save@srv`


Copier la sauvegarde la base de données sur la machine 2 *(serveur)* :

`$ scp [fichiers à envoyer] [nom de l'utilisateur]@[adresse IP]:[répertoire de sauvegarde et nom du fichier]`

***********************************************************************************************
## Le serveur de sauvegarde : machine M2

#### Création de la base de données des utilisateurs sur la machine 2 : 

Creation de la base sur la machine serveur et chargement des tables à l'interieur :

`$ sudo mysqladmin create users_db`

`$ sudo mysql users_db < save.sql`

Tester si les tables sont chargées :

`$ sudo mysql`

`$ use users_db`

`$ show tables`

`$ select * from user_tb`

***********************************************************************************************
*Création d'utilisateur :*
`$ sudo adduser [nom de l'utilisateur]`

*Changer d'utilisateur :*
`su [nom de l'utilisateur]`

***********************************************************************************************
#### Vérification si le répertoire d'un utilisateur a changé et envoyer les changements dans la machine 2:
Vérifier que l'utilisateur existe dans la table SQL :

- S'il existe :

	- Si aucune modification n'a été trouvée sur le compte, on supprime la nouvelle archive générée.
	- Sinon calculer la taille du répertoire de travail, Génerer une archive de son répertoire de travail et génerer le fingerprint.
	
- Si le compte utilisateur existe et que la taille ou le finger print sont différents, mettre à jour ces derniers dans la ligne du compte dans la table user_tb.

- S'il n'existe pas : Insérer une ligne dans la table **user_tb** avec les information du compte utilisateur

Lancer le script **transferArchivesAndDataBaseToM2.sh** pour envoyer les archive et la sauvegarde de la base de données vers la machine 2 (serveur).

## Vagrant/Vagrantfile

Création d'un fichier de configuration Vagrant

Télécharger une box de meme version:

`Vagrant init nom_de_la_box`

Vagrant file :


```ruby
Vagrant.configure(2) do |config|
 config.vm.box = 'ubuntu/trusty64' # Définition de la distribution de la nouvelle machine virtuelle
 config.vm.hostname = 'foo' # Définition du nom d'utilisateur de la machine
 config.vm.provision 'shell', path: 'http://192.168.56.1/transferArchivesAndDataBaseToMachine2.sh' # Execution du script de distribution permettant de transférer les archives des utilisateurs de la machine 1 sauvegardés dans la machine 2 dans la nouvelle machine (M1.clone)
 config.vm.provider :virtualbox do |vb|
  vb.name = 'M1.clone' # Définition du nom de la machine virtuelle
 end
end
```
