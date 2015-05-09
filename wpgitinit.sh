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
  echo "Usage: bash wpgit.sh httpsgitavecmdp gituseremail gitusername"
  exit $E_BADARGS
fi

# Création du repo local git et init
git init
git config  user.email $2
git config user.name $3
git remote add origin $1
git add .
git commit -a -m "commit init"
git push origin master

echo "================================================================="
echo "Git init ok."
echo "================================================================="
