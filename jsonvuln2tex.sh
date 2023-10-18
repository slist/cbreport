#!/bin/bash

helpFunction()
{
   echo "Usage: $0 <JSON file>"
   echo "\tJSON file contains a list of container images and their vulnerabilities"
   exit 1 # Exit script after printing help
}

if [ -z "$1" ]
then
   helpFunction
fi

jsonfile=$1
num_found=$(jq '.num_found' $1)

#echo ${num_found}

let num_found-=1

for i in `seq 0 ${num_found}`; do
	echo ""
	echo ""
	jq ".results | .[${i}] | .registry" $jsonfile |sed -z 's/\"//g'
	jq ".results | .[${i}] | .repo" $jsonfile |sed -z 's/\"//g'
	jq ".results | .[${i}] | .tag" $jsonfile |sed -z 's/\"//g'


	echo -n "\\criticalvulncbox{"
	jq ".results | .[${i}] | .vulnerabilities_summary | .CRITICAL | .amount" $jsonfile | sed -z 's/\n//g'

	echo -n "/"
	jq ".results | .[${i}] | .vulnerabilities_summary | .CRITICAL | .fixes" $jsonfile | sed -z 's/\n//g'
	echo "}"

	echo -n "\\highvulncbox{"
	jq ".results | .[${i}] | .vulnerabilities_summary | .HIGH | .amount" $jsonfile | sed -z 's/\n//g'

	echo -n "/"
	jq ".results | .[${i}] | .vulnerabilities_summary | .HIGH | .fixes" $jsonfile | sed -z 's/\n//g'
	echo "}"

	echo -n "\\mediumvulncbox{"
	jq ".results | .[${i}] | .vulnerabilities_summary | .MEDIUM | .amount" $jsonfile | sed -z 's/\n//g'

	echo -n "/"
	jq ".results | .[${i}] | .vulnerabilities_summary | .MEDIUM | .fixes" $jsonfile | sed -z 's/\n//g'
	echo "}"

	echo -n "\\lowvulncbox{"
	jq ".results | .[${i}] | .vulnerabilities_summary | .LOW | .amount" $jsonfile | sed -z 's/\n//g'

	echo -n "/"
	jq ".results | .[${i}] | .vulnerabilities_summary | .LOW | .fixes" $jsonfile | sed -z 's/\n//g'
	echo "}"

done

