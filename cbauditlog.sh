#!/bin/bash

source config.sh

FILE_AUDITLOG="auditlog.json"
TEX_FILE_DEVICES_TARGETVALUES="devices_targetvalues.tex"
TEX_FILE_DEVICES_OS="devices_os.tex"
FILE_REQUEST="request.txt"

echo "Download audit logs"
curl -H X-Auth-Token:${TOKEN} https://api-${SERVER}.conferdeploy.net/integrationServices/v3/auditlogs >${FILE_AUDITLOG} 2>/dev/null
jq '.notifications| .[] |.loginName' ${FILE_AUDITLOG} | sort | uniq |  sed 's/"//g'

exit 0 # End

############################################################################
# Other method : unsupported

cat <<EOF > ${FILE_REQUEST}
{
  "fromRow": 1,
  "maxRows": 200,
  "searchWindow": "TWO_WEEKS"",
  "sortDefinition": {
            "fieldName": "TIME",
            "sortOrder": "DESC"
    },
    "orgId": ${ORG},
    "highlight": false
}
EOF

#curl -X POST -H "X-Auth-Token:${TOKEN}" -H "Content-Type: application/json" -d @${FILE_REQUEST} https://api-${SERVER}.conferdeploy.net/appservices/v5/orgs/${ORG}/auditlog/find 

set -x

curl -X POST -H "X-Auth-Token:${TOKEN}" -H "Content-Type: application/json" -d @${FILE_REQUEST} https://defense-eu.conferdeploy.net/appservices/v5/orgs/${ORG}/auditlog/find 


