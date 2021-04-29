#!/bin/bash

#Setup all the input variables
for i in "$@"
do
case $i in
    -apiKey=*|--apikey=*)
    APIKEY="${i#*=}"
    shift 
    ;;
    -inputFile=*|--inputfile=*)
    INPUTFILE="${i#*=}"
    shift 
    ;;
    -serverBase=*|--serverbase=*)
    SERVERBASE="${i#*=}"
    shift 
    ;;
    -dataLocation=*|--datalocation=*)
    DATALOCATION="${i#*=}"
    shift 
    ;;
    -modelName=*|--modelname=*)
    MODELNAME="${i#*=}"
    shift 
    ;;   
    -modelEdition=*|--modeledition=*)
    MODELEDITION="${i#*=}"
    shift 
    ;;             

esac
done

#echo "APIKEY = ${APIKEY}"
#echo "INPUTFILE  = ${INPUTFILE}"
#echo "SERVERBASE  = ${SERVERBASE}"
#echo "DATALOCATION  = ${DATALOCATION}"
#echo "MODELNAME  = ${MODELNAME}"
#echo "MODELEDITION  = ${MODELEDITION}"

Header="Api-Key: $APIKEY"



#########################################################################################
#
#                            CHECK SEMARCHY VERSION
#
#########################################################################################

# Update the API endpoint
VERSIONAPI="/api/rest/admin/version"
VERSIONURL="$SERVERBASE$VERSIONAPI"

# Get the version
echo "Version API endpoint"
echo "VERSIONURL: $VERSIONURL"
echo ""
echo "Version response:" 
curl -i -X GET "$VERSIONURL" -H "$Header"
echo ""
echo ""


#########################################################################################
#
#                            IMPORT THE MODEL
#
#########################################################################################


#Update the API endpoint

importAPI="/api/rest/app-builder/models/$MODELNAME/editions/$MODELEDITION/content"
importURL="$SERVERBASE$importAPI"

# Import the exported model to the dev branch in Semarchy
echo "Importing open model to dev branch"
echo $importURL

echo ""
echo "Import of model response:"

curl -i -X POST -H "Content-Type: application/octet-stream"   -H "$Header"   -d "@$INPUTFILE" "$importURL"

echo ""

#########################################################################################
#
#                            DEPLOY THE MODEL
#
#########################################################################################

# Update the API endpoint
deployAPI="/api/rest/app-builder/data-locations/$DATALOCATION/deploy"
deployURL="$SERVERBASE$deployAPI"

# Set the body of the message
deployBody='{"'modelName'": "'$MODELNAME'", "modelEditionKey": "'$MODELEDITION'"}'
echo "Deploybody: $deployBody"

# Deploy the newly imported model to the data location
echo "Deploying model URL"
echo $deployURL

echo ""
echo ""

#RESPONSE='curl -X POST -H "$Headers2" -d "$deployBody" "$deployURL"'

echo "Deployment response:"
curl -i -X POST -H "$Header" -H "Content-Type: application/json" -d "$deployBody" "$deployURL"


#./devRelease.sh -apiKey=LSAqh3V.9AttjtiGQAWCsX97S0WEyjgtibTrSamArce -inputFile='Models/CEVAPhase1 [0.0].xml' -serverBase=http://localhost:8088/semarchy -dataLocation=DemoTest -modelName=DemoTest -modelEdition=0.0






























