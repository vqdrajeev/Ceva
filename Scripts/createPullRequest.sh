#!/bin/bash

# Setup all the input variables

for i in "$@"
do
case $i in
    -project=*|--project=*)
    PROJECT="${i#*=}"
    shift 
    ;;
    -repo=*|--repo=*)
    REPO="${i#*=}"
    shift 
    ;;
    -sourceBranch=*|--sourceBranch=*)
    SOURCEBRANCH="${i#*=}"
    shift 
    ;;
    -targetBranch=*|--targetBranch=*)
    TARGETBRANCH="${i#*=}"
    shift 
    ;;
    -title=*|--title=*)
    TITLE="${i#*=}"
    shift 
    ;;   
    -des=*|--des=*)
    DES="${i#*=}"
    shift 
    ;;
	-token=*|--token=*)
    TOKEN="${i#*=}"
    shift 
    ;; 

esac
done

bodyObj='{
"'sourceRefName'"="'refs/heads/$SOURCEBRANCH'",
  "'targetRefName'"= "'refs/heads/$TARGETBRANCH'",
  "'title'"= "'$TITLE'",
  "'description'"="'$DES'",
  }'

URL="github url pull request"

curl -u username:password -H "Content-Type: application/json" -H  -d "$bodyObj" "$URL"