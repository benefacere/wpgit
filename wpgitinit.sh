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
  echo "Usage: bash wpgitinit.sh httpsgitavecmdp gituseremail gitusername"
  exit $E_BADARGS
fi

# Fonction de sortie de script :
die() {
        echo $@ >&2 ;
        exit 1 ;
}

read -p "Dump de la base ? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
	read -p "Nom de la base : " nombdd
	rm -rf ./sqldump
	mkdir ./sqldump

	mysqldump -uroot -p --databases $nombdd | /bin/gzip -9 > ./sqldump/$nombdd.sql.gz
	[ $? -eq 0 ] || die "Impossible de faire le dump la base, mot de passe mysql incorrect ?" ;	
fi

# Création du repo local git et init
git init
git config user.email $2
git config user.name $3
git remote add origin $1
touch .gitignore
echo 'htdocs/wp-content/cache/*' > .gitignore
echo 'htdocs/wp-content/uploads/backwpup*' >> .gitignore
git add .
git commit -a -m "commit init"
git push origin master

echo "================================================================="
echo "Git init ok."
echo "================================================================="
