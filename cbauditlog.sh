#!/bin/bash

source config.sh

FILE_AUDITLOG="auditlog.json"
TEX_FILE_DEVICES_TARGETVALUES="devices_targetvalues.tex"
TEX_FILE_DEVICES_OS="devices_os.tex"

echo "Download audit logs"
curl -H X-Auth-Token:${TOKEN} https://api-${SERVER}.conferdeploy.net/integrationServices/v3/auditlogs >${FILE_AUDITLOG} 2>/dev/null

jq '.notifications| .[] |.loginName' ${FILE_AUDITLOG} | sort | uniq |  sed 's/"//g'

exit 0 # End
