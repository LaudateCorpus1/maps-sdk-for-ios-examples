#!/bin/bash -e

USAGE="Usage: bash $(basename "$0") key adminKey"

if [ "$#" -ne 2 ]; then
    echo "This script must be run with two arguments!"
    echo ${USAGE}
    exit 1
fi

if ! [ -x "$(command -v jq)" ]; then
  echo 'Error: jq is not installed.' >&2
  exit 1
fi

API_KEY=$1
ADMIN_KEY=$2


PROJECT_NAME_1="OnlineMapsSDK_GeofencingReport_1"
PROJECT_NAME_2="OnlineMapsSDK_GeofencingReport_2"


#Circle fance
FANCE_NAME_1="Amsterdam center"
COORDINATES_1="[4.899115, 52.372144]"


#Polygon fance
FANCE_NAME_2="Amsterdam garden"
COORDINATES_2="[[[4.906364, 52.366650], [4.913136, 52.371166], [4.926724, 52.367172], [4.916473, 52.363494], [4.906364, 52.366650]]]"


#Curl for creating a project 1
echo ""
echo "Creating ${PROJECT_NAME_1}..."

RESPONSE_1=`curl -s -XPOST -H "Content-type: application/json" -d '{"name": "'"${PROJECT_NAME_1}"'"}' "https://api.tomtom.com/geofencing/1/projects/project?key=${API_KEY}&adminKey=${ADMIN_KEY}"`

if jq -e . >/dev/null 2>&1 <<<"${RESPONSE_1}"; then
    MESSAGE_1=`echo ${RESPONSE_1} | jq -r '.message'`
    ID_1=`echo ${RESPONSE_1} | jq -r '.id'`
    NAME_1=`echo ${RESPONSE_1} | jq -r '.name'`

    if [ "$ID_1" == "null" ] && [ "$NAME_1" == "null" ]; then
        echo ${MESSAGE_1}
        exit 1
    else
        echo "Project '${NAME_1}' created with id: ${ID_1}"
    fi
else
    echo "Failed to parse JSON, or got false/null"
    echo ${RESPONSE_1}
    exit 1
fi


#Curl for creating a project 2
echo ""
echo "Creating ${PROJECT_NAME_2}..."

RESPONSE_2=`curl -s -XPOST -H "Content-type: application/json" -d '{"name": "'"${PROJECT_NAME_2}"'"}' "https://api.tomtom.com/geofencing/1/projects/project?key=${API_KEY}&adminKey=${ADMIN_KEY}"`

if jq -e . >/dev/null 2>&1 <<<"${RESPONSE_2}"; then
    MESSAGE_2=`echo ${RESPONSE_2} | jq -r '.message'`
    ID_2=`echo ${RESPONSE_2} | jq -r '.id'`
    NAME_2=`echo ${RESPONSE_2} | jq -r '.name'`

    if [ "$ID_2" == "null" ] && [ "$NAME_2" == "null" ]; then
        echo ${MESSAGE_2}
        exit 1
    else
        echo "Project '${NAME_2}' created with id: ${ID_2}"
    fi
else
    echo "Failed to parse JSON, or got false/null"
    echo ${RESPONSE_2}
    exit 1
fi


#Curl used for creating fence and assigning to single project
echo ""
echo "Creating ${FANCE_NAME_1} fence and assigning to single project..."

RESPONSE_FANCE_1=`curl -s -XPOST -H "Content-type: application/json" -d '{"name": "'"${FANCE_NAME_1}"'", "type": "Feature", "geometry": {"radius": 1300, "type": "Point", "shapeType": "Circle","coordinates": '"${COORDINATES_1}"'},"properties": {"Key": "Amsterdam"}}' "https://api.tomtom.com/geofencing/1/projects/${ID_2}/fence?key=${API_KEY}&adminKey=${ADMIN_KEY}"`

echo ${RESPONSE_FANCE_1}


#Curl used for creating fence and assigning it to two projects
echo ""
echo "Creating ${FANCE_NAME_2} fence and assigning it to two projects..."

RESPONSE_FANCE_2=`curl -s -XPOST -H "Content-type: application/json" -d '{"name": "'"${FANCE_NAME_2}"'","type": "Feature","projects": ["'${ID_1}'", "'${ID_2}'"],"geometry": {"type":"Polygon","coordinates": '"${COORDINATES_2}"'},"properties":{}}' "https://api.tomtom.com/geofencing/1/fences/fence?key=${API_KEY}&adminKey=${ADMIN_KEY}"`

echo ${RESPONSE_FANCE_2}

#Summary
echo ""
echo "Summary:"
echo "Project '${NAME_1}' created with id: ${ID_1}"
echo "Project '${NAME_2}' created with id: ${ID_2}"
