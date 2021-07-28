#!/bin/bash

#start tomcat fhir server
sh startup.sh

#Initiate Variables
HEADER_CONTENT_TYPE="Content-Type: application/fhir+json"
SERVER_URL="http://localhost:8080/fhir"
INPUT_FILE="transaction.json"  #json file with the FHIR request that contained the resources to load DB
HTTP_BODY=$(<${INPUT_FILE})

#color for echo output
RED='\033[0;31m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function isFHIRServerRunning {
    echo -e "${GREEN}Waiting for server to start apx. 35 second"
    sleep 35
    status_code=0
    count=0

    #waiting for HTTP 200 OK response code from server
    while [ "$status_code" -ne 200 ]
    do 
        sleep 4 
        echo -e "${YELLOW}$Check FHIR Server Attempted #:${count}"
        status_code=$(curl --head\
            --max-time 1\
            --request GET \
            --write-out %{http_code} --silent \
            --output /dev/null \
            ${SERVER_URL}/metadata)
        count=$(( $count + 1 ))
        
        if [[ "$status_code" -eq 200 ]]
        then
            echo -e "${GREEN}Server is up. Status Code: $status_code"
        else
            echo -e "${RED}Status Code: $status_code"
        fi 
    done
}

function callPOSTService {
    echo -e "${PURPLE}Calling URI (POST): " ${SERVER_URL}
    echo -e "body:" 
    echo -e "$HTTP_BODY"
    response=$(curl --include\
        --header "Content-Type: application/fhir+json" \
        --request POST \
        --data "${HTTP_BODY}" \
        ${SERVER_URL})
    echo -e "${RED}HTTP Response:"
    echo -e "${GREEN}$response"
}

isFHIRServerRunning
callPOSTService

#bring tomcat to foreground
tail -f $CATALINA_HOME/logs/catalina.out