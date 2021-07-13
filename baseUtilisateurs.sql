#DROP DATABASE IF EXISTS users_db; 
CREATE DATABASE IF NOT EXISTS users_db DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
USE users_db;

#DROP TABLE IF EXISTS user_tb;
CREATE TABLE IF NOT EXISTS user_tb (
  id int unsigned NOT NULL AUTO_INCREMENT,
  name varchar(64) NOT NULL,
  uid int unsigned,
  gid int unsigned,
  home varchar(128) NOT NULL,
  shell varchar(128) NOT NULL,
  taille int unsigned NOT NULL,
  fingerprint varchar(128) NOT NULL,
  PRIMARY KEY  (id),
  KEY type (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

LOAD XML LOCAL INFILE '/home/hs/Bureau/linux/linuxProject/donneesUtilisateurs.xml' INTO TABLE user_tb ROWS IDENTIFIED BY '<user>';
