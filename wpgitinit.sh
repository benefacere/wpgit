#!/bin/bash

# SE PLACER DANS HTDOCS
SITEURL=$(basename $PWD)
E_USAGE=64
if [ "$SITEURL" != "htdocs" ]
then
  echo "Usage: dans htdocs mais pas dans un autre répertoire"
  exit $E_USAGE
fi

EXPECTED_ARGS=3
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: bash wpgit.sh httpsgitavecmdp gituseremail gitusername bddname"
  exit $E_BADARGS
fi

# Fonction de sortie de script :
die() {
        echo $@ >&2 ;
        exit 1 ;
}

rm -rf ./sqldump
mkdir ./sqldump

mysqldump -uroot -p --databases $4 | /bin/gzip -9 > ./sqldump/$4.sql.gz
[ $? -eq 0 ] || die "Impossible de faire le dump la base, mot de passe mysql incorrect ?" ;

# Création du repo local git et init
git init
git config user.email $2
git config user.name $3
git remote add origin $1
touch .gitignore
echo 'htdocs/wp-content/cache/*' > .gitignore
echo 'htdocs/wp-content/uploads/backwpup*' >> .gitignore
git add .
git commit -m "commit init"
git push origin master

echo "================================================================="
echo "Git init ok."
echo "================================================================="
