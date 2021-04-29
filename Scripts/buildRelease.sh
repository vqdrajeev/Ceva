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
    -devModelEdition=*|--devModelEdition=*)
    DEVMODELEDITION="${i#*=}"
    shift 
    ;;
    -o=*|--outputFolderLocation=*)
    OUTPUTFOLDERLOCATION="${i#*=}"
    shift 
    ;;   
    -r=*|--releaseDescription=*)
    RELEASEDESCRIPTION="${i#*=}"
    shift 
    ;;	

esac
done

###################################################################################################
#
#                            SETUP VARIABLE
#
###################################################################################################

# Create all the working variables the rest of the script uses
header="Api-Key: $APIKEY" 
openModelFile="$OUTPUTFOLDERLOCATION\\$MODELNAME [$DEVMODELEDITION].xml"
description='{"description":"'$RELEASEDESCRIPTION'"}'

echo "header: $header"
echo "description: $description"
echo "serverbase: $SERVERBASE"
echo "Api-Key: $APIKEY"
echo "ModelName: $MODELNAME"
echo "devModelEdition: $DEVMODELEDITION"
echo "openModelFile: $openModelFile"

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

###################################################################################################
#
#                            PERFORM THE EXPORT OF THE CURRENT MODEL
#
###################################################################################################

exportAPI="/api/rest/app-builder/models/$MODELNAME/editions/$DEVMODELEDITION/content"
exportURL="$SERVERBASE$exportAPI"

# Perform the export
echo "Exporting open model"
echo $exportURL

curl -X GET -H "$header" "$exportURL" > temp.xml
#echo "Export response: $status"

# Format the XML file to be loaded
echo "Prettifying XML export"
sed 's/</\n</g' temp.xml | head
sed 's/</\n</g' temp.xml > "$openModelFile"



 
###################################################################################################
#
#                            FIND THE MODEL TO IMPORT OVER
#
###################################################################################################

modelAPI="/api/rest/app-builder/models/$MODELNAME/editions"
modelURL="$SERVERBASE$modelAPI"
#releaseModelKey=""

# Find the model edition to override
echo "Retrieving model to override"
echo ""

# Find the maximum key.  This will always be the one we want to release into (or at least it should be close)

curl -s "$modelURL" -H "$header" > releaseModelInfo.json

releaseModelKey="`jq '[.[].key] | max' releaseModelInfo.json| tr -d '"'`"

echo "Model to override is ${releaseModelKey}"


###################################################################################################
#
#                            IMPORT THE MODEL TO THE RELEASE BRANCH
#
###################################################################################################

# Update the API endpoint
importAPI="/api/rest/app-builder/models/$MODELNAME/editions/$releaseModelKey/content"
importURL="$SERVERBASE$importAPI"

# Import the exported model to the release branch in Semarchy

echo "Importing open model to release branch"
echo $importURL
echo ""
echo "Import of model response:"
curl -i -X POST -H "Content-Type: application/octet-stream"   -H "$header"   -d "@$openModelFile" "$importURL"

###################################################################################################
#
#                            CLOSE THE RELEASE BRANCH
#
###################################################################################################

closeAPI="/api/rest/app-builder/models/$MODELNAME/editions/$releaseModelKey/close"
closeURL="$SERVERBASE$closeAPI"

# Close the newly imported release
echo "Closing release model"
echo ""
echo "Import of model response:"
echo ""
curl -i -X POST -H "Content-Type: application/json"   -H "$header"   -d "$description" "$closeURL"

###################################################################################################
#
#                            EXPORT THE CLOSED RELEASE BRANCH
#
###################################################################################################

exportReleaseAPI="/api/rest/app-builder/models/$MODELNAME/editions/$releaseModelKey/content"
exportReleaseURL="$SERVERBASE$exportReleaseAPI"
closedModelFile="$OUTPUTFOLDERLOCATION\\$MODELNAME [$releaseModelKey].xml"

# Export the newly closed release branch
echo "Export release model"

curl -X GET -H "$header" "$exportReleaseURL" > temp.xml

#check whether it is successfully exported

# Format the XML file to be loaded
echo "Prettifying XML export"

sed 's/</\n</g' temp.xml > "$closedModelFile"

# Remove the temp files
echo "Cleaning up temp files"
rm temp.xml
rm releaseModelInfo.json

echo "temp.xml , releaseModelInfo.json Files deleted"


#./buildRelease.sh -apiKey=LSAqh3V.9AttjtiGQAWCsX97S0WEyjgtibTrSamArce -serverBase=http://localhost:8088/semarchy -modelName=DemoTest -devModelEdition=0.0 -o='Models' -r='This is test. Building release for DemoTest [0.0]'



























