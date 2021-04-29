#!/bin/bash

# Setup all the input variables

for i in "$@"
do
case $i in
    -apiKey=*|--apiKey=*)
    APIKEY="${i#*=}"
    shift 
    ;;
    -serverBase=*|--serverBase=*)
    SERVERBASE="${i#*=}"
    shift 
    ;;
    -modelName=*|--modelName=*)
    MODELNAME="${i#*=}"
    shift 
    ;;
    -inputFolder=*|--inputfolder=*)
    INPUTFOLDER="${i#*=}"
    shift 
    ;;
    -dataLocation=*|--datalocation=*)
    DATALOCATION="${i#*=}"
    shift 
    ;;   
  
esac
done

header="Api-Key: $APIKEY" 

#########################################################################################
#
#                            CHECK SEMARCHY VERSION
#
#########################################################################################

# Update the API endpoint
versionAPI="/api/rest/admin/version"
versionURL="$SERVERBASE$versionAPI"

# Get the version
echo "Version API endpoint"
echo $versionURL
echo ""
echo "Version response:" 
curl -i -X GET "$versionURL" -H "$header"
echo ""
echo ""

#########################################################################################
#
#                            FIND THE MODEL TO IMPORT
#
#########################################################################################

# Get the file to load in 

inputFolder="$INPUTFOLDER"
echo "inputFolder: $inputFolder"
cd $inputFolder
inputFile="`ls -t1 | head -n 1`"
echo "inputFile: $inputFile"

# Save that model edition

request="${inputFile#*[}"
modelEdition="${request%]*}"
echo "modelEdition: $modelEdition"

#########################################################################################
#
#                            IMPORT THE MODEL
#
#########################################################################################

# Update the API endpoint
importAPI="/api/rest/app-builder/models/$MODELNAME/editions/$modelEdition/content"
importURL="$SERVERBASE$importAPI"

# Import the exported model to Semarchy
echo "Importing open model to Semarchy"
echo $importURL

echo ""
echo "Import of model response:"
curl -i -X POST -H "Content-Type: application/octet-stream"   -H "$header"   -d "@$inputFile" "$importURL"

#########################################################################################
#
#                            DEPLOY THE MODEL
#
#########################################################################################

# Update the API endpoint
deployAPI="/api/rest/app-builder/data-locations/$DATALOCATION/deploy"
deployURL="$SERVERBASE$deployAPI"

# Set the body of the message
deployBody='{"'modelName'": "'$MODELNAME'", "modelEditionKey": "'$modelEdition'"}'
echo "Deploybody: $deployBody"

# Deploy the newly imported model to the data location
echo "Deploying model URL"
echo $deployURL

echo ""
echo ""

echo "Deployment response:"
curl -i -X POST -H "$header" -H "Content-Type: application/json" -d "$deployBody" "$deployURL"


#./testRelease.sh -apiKey=LSAqh3V.9AttjtiGQAWCsX97S0WEyjgtibTrSamArce -inputFolder="Models" -serverBase=http://localhost:8088/semarchy -dataLocation=DemoTest -modelName=DemoTest




























