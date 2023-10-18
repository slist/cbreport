#!/bin/bash

source config.sh

FILE_METADATA="metadata.json"
FILE_ORG_SUMMARY="org_summary.json"
FILE_CLUSTER_LIST="cluster_list.txt"
FILE_REGISTRY_LIST="registry_list.txt"
FILE_NAMESPACE_LIST="namespace_list.txt"
FILE_REPOSITORY_LIST="repository_list.txt"

FILE_REQUEST="request.txt"
FILE_VULN_HISTORY="vuln_history.json"
FILE_INVENTORY="inventory.json"
FILE_CRITICAL="critical.json"
FILE_HIGH="high.json"
FILE_DEPLOYED="deployed.json"

FILE_HARDENING_POLICIES="hardeningpolicies.json"
TEX_FILE_HARDENING_POLICIES="hardeningpolicies.tex"

TEX_FILE_CRITICAL="critical.tex"
TEX_FILE_HIGH="high.tex"

rm -f ${TEX_FILE_CRITICAL}
rm -f ${TEX_FILE_HIGH}

# Get hardening policies
curl -H X-Auth-Token:${TOKEN} https://api-${SERVER}.conferdeploy.net/containers/v1/orgs/${ORG}/guardrails/management/policies >${FILE_HARDENING_POLICIES} 2>/dev/null

num_found=$(jq '.items | length' ${FILE_HARDENING_POLICIES})
echo "Found ${num_found} hardening policies"

let num_found-=1

<<comment
for i in `seq 0 ${num_found}`; do
	echo "--"
	echo "Policy ${i}"
	echo -n "Name: "
	jq ".items | .[${i}] | .name" ${FILE_HARDENING_POLICIES}
	echo -n "Scope: "
	jq ".items | .[${i}] | .scope_metadata | .scope_name" ${FILE_HARDENING_POLICIES}
	echo -n "Exceptions: "
	jq ".items | .[${i}] | .exceptions_count" ${FILE_HARDENING_POLICIES}
	echo -n "Violations: "
	jq ".items | .[${i}] | .violations_count" ${FILE_HARDENING_POLICIES}
done
comment

rm -f ${TEX_FILE_HARDENING_POLICIES}
for i in `seq 0 ${num_found}`; do
	jq ".items | .[${i}] | .name" ${FILE_HARDENING_POLICIES} | sed 's/"//g' | tr -d '\n' >>${TEX_FILE_HARDENING_POLICIES}
	echo -n " & " >>${TEX_FILE_HARDENING_POLICIES}

	jq ".items | .[${i}] | .scope_metadata | .scope_name" ${FILE_HARDENING_POLICIES} | sed 's/"//g' | tr -d '\n' >>${TEX_FILE_HARDENING_POLICIES}
	echo -n " & " >>${TEX_FILE_HARDENING_POLICIES}

	jq ".items | .[${i}] | .exceptions_count" ${FILE_HARDENING_POLICIES} |tr -d '\n' >>${TEX_FILE_HARDENING_POLICIES}
	echo -n " & " >>${TEX_FILE_HARDENING_POLICIES}

	jq ".items | .[${i}] | .violations_count" ${FILE_HARDENING_POLICIES} | tr -d '\n' >>${TEX_FILE_HARDENING_POLICIES}
	echo "\\\\" >>${TEX_FILE_HARDENING_POLICIES}
	echo "\\hline" >>${TEX_FILE_HARDENING_POLICIES}

	policy_id=$(jq ".items | .[${i}] | .policy_id" ${FILE_HARDENING_POLICIES} | sed 's/"//g')
	echo ${policy_id}
done
echo "\\end{tabular}" >>${TEX_FILE_HARDENING_POLICIES}

# Get Kubernetes cluster list
curl -H X-Auth-Token:${TOKEN} https://api-${SERVER}.conferdeploy.net/containers/v1beta/orgs/${ORG}/inventory/overview/metadata >${FILE_METADATA} 2>/dev/null
jq '.clusters | .[]' ${FILE_METADATA} | sed 's/"//g' >${FILE_CLUSTER_LIST}
echo ""
echo "--------------------------------"
echo "Cluster list"
echo "--------------------------------"
cat ${FILE_CLUSTER_LIST}


echo -n "\\nicecounter{" >>devices_os.tex
cat ${FILE_CLUSTER_LIST} | wc -l | tr -d '\n' >>devices_os.tex
echo "}{Kubernetes clusters}" >>devices_os.tex

jq '.namespaces | .[]' ${FILE_METADATA} | sed 's/"//g' >${FILE_NAMESPACE_LIST}
echo ""
echo "--------------------------------"
echo "Namespace list"
echo "--------------------------------"
cat ${FILE_NAMESPACE_LIST}

jq '.repositories | .[]' ${FILE_METADATA} | sed 's/"//g' >${FILE_REPOSITORY_LIST}
echo ""
echo "--------------------------------"
echo "Repository list"
echo "--------------------------------"
cat ${FILE_REPOSITORY_LIST}


#Get Org summary (See https://developer.carbonblack.com/reference/carbon-black-cloud/container/latest/vulnerabilities-api/ )
curl -H X-Auth-Token:${TOKEN} https://api-${SERVER}.conferdeploy.net/containers/v1beta/orgs/${ORG}/vulnerabilities/org_summary >${FILE_ORG_SUMMARY} 2>/dev/null
echo ""
echo "--------------------------------"
echo "Org summary"
echo "--------------------------------"
jq . ${FILE_ORG_SUMMARY}



echo ""
echo "--------------------------------"
echo "Get Org inventory"
echo "--------------------------------"
echo ""

cat <<EOF > ${FILE_REQUEST}
{
  "query": "",
  "start": 0,
  "rows": 10000,
  "sort": [
        {
            "field": "last_scanned",
            "order": "DESC"
        }
    ]
}
EOF
curl -X POST -H "X-Auth-Token:${TOKEN}" -H "Content-Type: application/json" -d @${FILE_REQUEST} https://api-${SERVER}.conferdeploy.net/containers/v1beta/orgs/${ORG}/inventory/repositories/_search >${FILE_INVENTORY}  2>/dev/null
jq . ${FILE_INVENTORY}

echo ""
echo "--------------------------------"
echo "Get registry list"
echo "--------------------------------"
echo ""
jq '.results | .[] | .registry' ${FILE_INVENTORY} |sort |uniq | sed 's/"//g' >${FILE_REGISTRY_LIST}
cat ${FILE_REGISTRY_LIST}

#For each Kubernetes cluster,
while read -r cluster; do
    echo ""
    echo "--------------------------------"
    echo "Cluster: ${cluster}"
    echo "--------------------------------"

    echo ""
    echo "--------------------------------"
    echo "Get Scan status"
    echo "--------------------------------"
    echo ""

    cat <<EOF > ${FILE_REQUEST}
{
    "criteria": {
        "clusters": [
            "${cluster}"
        ]
    }
}
EOF

    curl -X POST -H "X-Auth-Token:${TOKEN}" -H "Content-Type: application/json" -d @${FILE_REQUEST} https://api-${SERVER}.conferdeploy.net/containers/v1beta/orgs/${ORG}/inventory/overview/scan_status 2>/dev/null


    echo ""
    echo "--------------------------------"
    echo "Get vulnerabilities history"
    echo "--------------------------------"
    echo ""


    cat <<EOF > ${FILE_REQUEST}
{
    "criteria": {
        "time": {
            "range": "-30d"
        },
        "clusters": [
            "${cluster}"
        ]
    }
}
EOF

    curl -X POST -H "X-Auth-Token:${TOKEN}" -H "Content-Type: application/json" -d @${FILE_REQUEST} https://api-${SERVER}.conferdeploy.net/containers/v1beta/orgs/${ORG}/inventory/overview/vulnerabilities_history >${cluster}_${FILE_VULN_HISTORY}  2>/dev/null
    jq . ${cluster}_${FILE_VULN_HISTORY}

    echo ""
    echo "----------------------------------------"
    echo "Get images with critical vulnerabilities"
    echo "----------------------------------------"
    echo ""

cat <<EOF > ${FILE_REQUEST}
{
    "query": "",
    "start": 0,
    "rows": 10000,
    "sort": [
        {
            "field": "vulnerabilities",
            "order": "DESC"
        }
    ],
    "criteria": {
        "is_running": true,
        "vulnerabilities":["CRITICAL"],
        "clusters": [
            "${cluster}"
        ]
     }
}
EOF
    curl -X POST -H "X-Auth-Token:${TOKEN}" -H "Content-Type: application/json" -d @${FILE_REQUEST} https://api-${SERVER}.conferdeploy.net/containers/v1beta/orgs/${ORG}/inventory/images/_search >${cluster}_${FILE_CRITICAL} 2>/dev/null
    jq . ${cluster}_${FILE_CRITICAL}


    jq .num_found ${cluster}_${FILE_CRITICAL} >${cluster}_critical.num_found.txt


    ./jsonvuln2tex.sh ${cluster}_${FILE_CRITICAL} >${cluster}_${TEX_FILE_CRITICAL} 
    echo -n "\\subsection{${cluster}}" >> ${TEX_FILE_CRITICAL}
    cat ${cluster}_${TEX_FILE_CRITICAL} >> ${TEX_FILE_CRITICAL}
    rm -f ${cluster}_${TEX_FILE_CRITICAL}

    echo ""
    echo "------------------------------------"
    echo "Get images with high vulnerabilities"
    echo "------------------------------------"
    echo ""

cat <<EOF > ${FILE_REQUEST}
{
    "query": "",
    "start": 0,
    "rows": 10000,
    "sort": [
        {
            "field": "vulnerabilities",
            "order": "DESC"
        }
    ],
    "criteria": {
        "is_running": true,
        "vulnerabilities":["HIGH"],
        "clusters": [
            "${cluster}"
        ]
     }
}
EOF
    curl -X POST -H "X-Auth-Token:${TOKEN}" -H "Content-Type: application/json" -d @${FILE_REQUEST} https://api-${SERVER}.conferdeploy.net/containers/v1beta/orgs/${ORG}/inventory/images/_search >${cluster}_${FILE_HIGH} 2>/dev/null
    jq . ${cluster}_${FILE_HIGH}

    echo ""
    echo "--------------------------------------"
    echo "Get vulnerabilities in deployed images"
    echo "--------------------------------------"
    echo ""


cat <<EOF > ${FILE_REQUEST}
{
    "query": "",
    "start": 0,
    "rows": 10000,
    "sort": [
        {
            "field": "vulnerabilities",
            "order": "DESC"
        }
    ],
    "criteria": {
        "is_running": true,
        "clusters": [
            "${cluster}"
        ]
     }
}
EOF
    curl -X POST -H "X-Auth-Token:${TOKEN}" -H "Content-Type: application/json" -d @${FILE_REQUEST} https://api-${SERVER}.conferdeploy.net/containers/v1beta/orgs/${ORG}/inventory/images/_search >${cluster}_${FILE_DEPLOYED} 2>/dev/null
    jq . ${cluster}_${FILE_DEPLOYED}


done < ${FILE_CLUSTER_LIST}

# Clean up
rm ${FILE_REQUEST}

exit 0 # End

