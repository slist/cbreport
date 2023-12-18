#!/bin/bash

source config.sh

#See doc: https://developer.carbonblack.com/reference/carbon-black-cloud/container/latest/setup-api

curl -H X-Auth-Token:${TOKEN} https://api-${SERVER}.conferdeploy.net/containers/v1/orgs/${ORG}/deploy/cli_instances/download_links >download_links.json 2>/dev/null

cbctl_version=$(jq .linux.version download_links.json | sed 's/"//g')
cbctl_download_link=$(jq .linux.download_link download_links.json | sed 's/"//g')
cbctl_sha256=$(jq .linux.sha256_sum download_links.json | sed 's/"//g')

rm -f cbctl cbctl_${cbctl_version}
wget ${cbctl_download_link}

# Test to modify cbctl
# echo "test" >>cbctl

cbctl_sha2=$(sha256sum -b cbctl | awk '{print $1}')

if [ "$cbctl_sha256" = "$cbctl_sha2" ]; then
	echo "SHA256 is correct."
	echo "Install cbctl in /usr/local/bin/"
	echo "(will ask your password soon)"
else
	echo "SHA256 is NOT correct! Try again."
	exit 1
fi

chmod +x cbctl
sudo rm -f /usr/local/bin/cbctl /usr/local/bin/cbctl_${cbctl_version}
sudo mv cbctl /usr/local/bin/cbctl_${cbctl_version}
sudo ln -s /usr/local/bin/cbctl_${cbctl_version} /usr/local/bin/cbctl

