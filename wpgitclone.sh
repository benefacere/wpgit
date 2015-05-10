#!/bin/bash

# SE PLACER A LA BASE DU REPERTOIRE VIRTUEL, PAS DANS LE REPERTOIRE HTDOCS
SITEURL=$(basename $PWD)
E_USAGE=64
if [ "$SITEURL" == "htdocs" ]
then
  echo "Usage: pas dans htdocs mais dans le répertoire en dessous, celui du nom de domaine"
  exit $E_USAGE
fi

EXPECTED_ARGS=3
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: bash wpgitclone.sh httpsgit gituseremail gitusername"
  exit $E_BADARGS
fi

#NETTOYAGE
rm -rf .git
rm -rf .gitignore
rm -rf sqldump
echo "git deleted"
rm -rf htdocs/*
echo "Repertoire htdocs clean"
if [ -f htdocs/.htaccess ]
then
	rm htdocs/.htaccess
	echo "Delete htaccess"
else
	echo "Pas de htaccess a supprimer"
fi
if [ -f .htpasswd ]
then
	rm .htpasswd
	echo "Delete htpasswd"
else
	echo "Pas de htpasswd a supprimer"
fi

# GIT
git init
git remote add origin $1
git config user.email $2
git config user.name $3
git fetch
read -p "Restore tag (attention, cela va creer une branche) ? <y/N> " avectag
if [[ $avectag == "y" || $avectag == "Y" || $avectag == "yes" || $avectag == "Yes" ]]
then
	read -p "Nom tag : " letag
	git checkout -b version$letag $letag
else
	git checkout -t origin/master
fi

# Fonction de sortie de script :
die() {
        echo $@ >&2 ;
        exit 1 ;
}

read -p "Restore de la base ? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
	read -p "Nom de la base : " nombdd
	read -p "Nom user : " userbdd
	read -p "Passwd de la base : " passwdbdd
	
	cd sqldump
	gunzip $nombdd.sql.gz
	cd ..
		
	# CREATION DE LA BASE
	MYSQL=`which mysql`

	D0="GRANT USAGE ON *.* TO $userbdd@localhost;"
	D1="DROP USER $userbdd@localhost;" 
	D2="DROP DATABASE IF EXISTS $nombdd;" 
	Q1="CREATE DATABASE IF NOT EXISTS $nombdd;"
	Q2="GRANT USAGE ON *.* TO $userbdd@localhost IDENTIFIED BY '$passwdbdd';"
	Q3="GRANT ALL PRIVILEGES ON $nombdd.* TO $userbdd@localhost;"
	Q4="FLUSH PRIVILEGES;"
	Q5="USE $nombdd;"
	Q6="source ./sqldump/$nombdd.sql;"
	SQL="${D0}${D1}${D2}${Q1}${Q2}${Q3}${Q4}${Q5}${Q6}"

	$MYSQL -uroot -p -e "$SQL"
	[ $? -eq 0 ] || die "Impossible de créer la base et le user, mot de passe mysql incorrect ?" ;		
fi

# SECU (soit il est dans htdocs soit a la racine)
if [ -f htdocs/wp-config.php ]
then
	chmod 600 htdocs/wp-config.php
else
	chmod 600 wp-config.php
fi
echo "chmod 600 wp-config"

echo "================================================================="
echo "Git clone ok."
echo "================================================================="
