#!/bin/bash

# Setup all the input variables
commitMessage=$@

git branch -a	

git fetch --all

echo "Hard Reset to Dev Branch"
git reset --hard orgin/dev

git checkout dev

git pull

echo "Get Status"
git status

echo "Add all the missing files"
git add -A

echo "Commit the new files"
git commit -m '"'$commitMessage'"'

echo "Push the commit back to Dev"
git push