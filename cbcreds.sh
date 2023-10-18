#/bin/bash

if [ -z "$1" ]
  then
    echo "No argument supplied"
    exit 1 # Error, no arg supplied
fi

TOKEN=$(sed -nr "/^\[$1\]/ { :l /^token[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ~/.carbonblack/credentials.cbc)
echo "TOKEN=\"${TOKEN}\""

ORG=$(sed -nr "/^\[$1\]/ { :l /^org_key[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ~/.carbonblack/credentials.cbc)
echo "ORG=\"${ORG}\""

URL=$(sed -nr "/^\[$1\]/ { :l /^url[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ~/.carbonblack/credentials.cbc)
SERVER=$(
  case "${URL}" in
	  ("https://defense.conferdeploy.net") echo "prod05" ;;
	  ("https://defense-eu.conferdeploy.net") echo "prod06" ;;
	  (*) echo "unknown URL" ;;
  esac)
echo "SERVER=\"${SERVER}\""

