#!/bin/bash

# Remplir la base de données en utilisant le fichier sql
sudo mysql -e "SOURCE /home/hs/Bureau/linux/sql/creation_de_la_base_de_donne_depuis_un_fichier_xml.sql" --local-infile=1

echo "******* La base de données users_db a été tronquée puis alimentée avec le fichier sql /home/hs/Bureau/linux/sql/creation_de_la_base_de_donne_depuis_un_fichier_xml.sql."

# Archiver la base de données
sudo mysqldump users_db > /home/hs/Bureau/linux/sql/save/users_db_save.sql

echo "******* Une sauvegarde de la base de données users_db a été crée /home/hs/Bureau/linux/sql/save/users_db_save.sql."


