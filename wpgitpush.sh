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
  echo "Usage: bash wpgitpush.sh mode gituseremail gitusername"
  echo "Valeurs: mode = justcommit ou mode = full"
  exit $E_BADARGS
fi

# Fonction de sortie de script :
die() {
        echo $@ >&2 ;
        exit 1 ;
}

if [ $1 != "justcommit" ]
then
	read -p "Dump de la base ? <y/N> " prompt
	if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
	then
		read -p "Nom de la base : " nombdd
		rm -rf ./sqldump
		mkdir ./sqldump

		mysqldump -uroot -p --databases $nombdd | /bin/gzip -9 > ./sqldump/$nombdd.sql.gz
		[ $? -eq 0 ] || die "Impossible de faire le dump la base, mot de passe mysql incorrect ?" ;	
	fi
fi

# Creation du repo local git et init si besoin
if [ ! -d .git ]
then
	if [ $1 == "justcommit" ]
	then
		echo "Git push ko, init pas possible en mode justcommit."
		exit 1 ;
	fi
	
	read -p "HTTPS GIT (avec ou sans mdp) : " httpsgit
	git init
	git remote add origin $httpsgit
	touch .gitignore
	echo 'htdocs/wp-content/cache/*' > .gitignore
	echo 'htdocs/wp-content/uploads/backwpup*' >> .gitignore
	echo 'wpgitpush.sh' >> .gitignore
	echo 'wpgitclone.sh' >> .gitignore
	# echo 'wp-config.php' >> .gitignore
	# echo 'htdocs/wp-config.php' >> .gitignore
	# echo 'htdocs/.htaccess' >> .gitignore
	# echo 'htdocs/robots.txt' >> .gitignore
fi	

git config user.email $2
git config user.name $3

git add -A
ladate=`date +"%d-%m-%y"`
git commit -a -m "commit $ladate"

if [ $1 != "justcommit" ]
then
	read -p "Version Tag ? <y/N> " gittag
	if [[ $gittag == "y" || $gittag == "Y" || $gittag == "yes" || $gittag == "Yes" ]]
	then
		read -p "Nom Tag (ex : v1.0) : " nomtag
		git tag -a $nomtag -m 'version $nomtag'
		git push --tags
	fi	
fi
git push origin master

echo "================================================================="
echo "Git push ok."
echo "================================================================="