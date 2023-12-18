#!/bin/bash

source config.sh

FILE_METADATA="metadata.json"
FILE_ORG_SUMMARY="org_summary.json"

FILE_CLUSTER_LIST="cluster_list.txt"
FILE_CLUSTER_DIFF="cluster_list_diff.txt"
TEX_CLUSTER_DIFF="clusterlistdiff.tex"

FILE_REGISTRY_LIST="registry_list.txt"
FILE_REGISTRY_DIFF="registry_list_diff.txt"
TEX_REGISTRY_DIFF="registrylistdiff.tex"

FILE_NAMESPACE_LIST="namespace_list.txt"
FILE_NAMESPACE_DIFF="namespace_list_diff.txt"
TEX_NAMESPACE_DIFF="namespacelistdiff.tex"

FILE_REPOSITORY_LIST="repository_list.txt"

FILE_REQUEST="request.txt"
FILE_VULN_HISTORY="vuln_history.json"
FILE_INVENTORY="inventory.json"
FILE_CRITICAL="critical.json"
FILE_HIGH="high.json"
FILE_DEPLOYED="deployed.json"
FILE_RUNTIME_ALERTS="runtime_alerts.txt"


FILE_HARDENING_POLICIES="hardeningpolicies.json"
TEX_FILE_HARDENING_POLICIES="hardeningpolicies.tex"

TEX_FILE_CRITICAL="critical.tex"
TEX_FILE_HIGH="high.tex"
TEX_FILE_MALWARE="malware.tex"

TEX_FILE_ALERT_REASON="alertreason.tex"
TEX_FILE_VULN_OVERVIEW="vulnoverview.tex"
TEX_FILE_RUNTIME_ALERT="runtimealert.tex"



rm -f ${TEX_FILE_CRITICAL}
touch ${TEX_FILE_CRITICAL}
rm -f ${TEX_FILE_HIGH}
touch ${TEX_FILE_HIGH}
rm -f ${TEX_FILE_MALWARE}
touch ${TEX_FILE_MALWARE}

echo ""
echo "--------------------------------"
echo "Hardening policies"
echo "--------------------------------"

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

	jq ".items | .[${i}] | .violations_count" ${FILE_HARDENING_POLICIES} | sed 's/null/0/g' | tr -d '\n' >>${TEX_FILE_HARDENING_POLICIES}
	echo "\\\\" >>${TEX_FILE_HARDENING_POLICIES}
	echo "\\hline" >>${TEX_FILE_HARDENING_POLICIES}

	#policy_id=$(jq ".items | .[${i}] | .policy_id" ${FILE_HARDENING_POLICIES} | sed 's/"//g')
	#echo ${policy_id}
done
echo "\\end{tabular}" >>${TEX_FILE_HARDENING_POLICIES}

# Get Kubernetes cluster list
curl -H X-Auth-Token:${TOKEN} https://api-${SERVER}.conferdeploy.net/containers/v1beta/orgs/${ORG}/inventory/overview/metadata >${FILE_METADATA} 2>/dev/null
mv ${FILE_CLUSTER_LIST} ${FILE_CLUSTER_LIST}.old 2>/dev/null
jq '.clusters | .[]' ${FILE_METADATA} | sed 's/"//g' >${FILE_CLUSTER_LIST}
echo ""
echo "--------------------------------"
echo "Cluster list"
echo "--------------------------------"
cat ${FILE_CLUSTER_LIST}

#Compute diff
diff -au ${FILE_CLUSTER_LIST}.old ${FILE_CLUSTER_LIST} |grep -E "^[+-]" >${FILE_CLUSTER_DIFF}
./diff2tex.sh ${FILE_CLUSTER_DIFF} >${TEX_CLUSTER_DIFF}

#Remove K8s counter if already present in the file
sed -i '/Kubernetes clusters/d' devices_os.tex

echo -n "\\nicecounter{" >>devices_os.tex
cat ${FILE_CLUSTER_LIST} | wc -l | tr -d '\n' >>devices_os.tex
echo "}{Kubernetes clusters}" >>devices_os.tex

mv ${FILE_NAMESPACE_LIST} ${FILE_NAMESPACE_LIST}.old 2>/dev/null
jq '.namespaces | .[]' ${FILE_METADATA} | sed 's/"//g' >${FILE_NAMESPACE_LIST}
echo ""
echo "--------------------------------"
echo "Namespace list"
echo "--------------------------------"
echo -n "Found "
cat ${FILE_NAMESPACE_LIST} |wc -l

#Compute diff
diff -au ${FILE_NAMESPACE_LIST}.old ${FILE_NAMESPACE_LIST} |grep -E "^[+-]" >${FILE_NAMESPACE_DIFF}
./diff2tex.sh ${FILE_NAMESPACE_DIFF} >${TEX_NAMESPACE_DIFF}

jq '.repositories | .[]' ${FILE_METADATA} | sed 's/"//g' >${FILE_REPOSITORY_LIST}
echo ""
echo "--------------------------------"
echo "Repository list"
echo "--------------------------------"
echo -n "Found "
cat ${FILE_REPOSITORY_LIST} |wc -l


#Get Org summary (See https://developer.carbonblack.com/reference/carbon-black-cloud/container/latest/vulnerabilities-api/ )
curl -H X-Auth-Token:${TOKEN} https://api-${SERVER}.conferdeploy.net/containers/v1beta/orgs/${ORG}/vulnerabilities/org_summary >${FILE_ORG_SUMMARY} 2>/dev/null
echo ""
echo "--------------------------------"
echo "Org summary"
echo "--------------------------------"
#jq . ${FILE_ORG_SUMMARY}

rm -f ${TEX_FILE_VULN_OVERVIEW}

for sev in CRITICAL HIGH MEDIUM LOW UNKNOWN
do
    echo -n "\\nicevuln{" >> ${TEX_FILE_VULN_OVERVIEW}
    jq ".severity_summary | .${sev} | .vulnerabilities" org_summary.json | tr -d '\n' >> ${TEX_FILE_VULN_OVERVIEW}
    echo "}{${sev}}{V${sev}}" >> ${TEX_FILE_VULN_OVERVIEW}
done

#echo "" >> ${TEX_FILE_VULN_OVERVIEW}
#echo "\\vskip5pt" >> ${TEX_FILE_VULN_OVERVIEW}

echo "\\begin{center}" >> ${TEX_FILE_VULN_OVERVIEW}

echo "\\rule{0.5\\linewidth}{1pt}" >> ${TEX_FILE_VULN_OVERVIEW}
echo "" >> ${TEX_FILE_VULN_OVERVIEW}
echo "\\vskip5pt" >> ${TEX_FILE_VULN_OVERVIEW}

echo -n "\\nicecounter{" >> ${TEX_FILE_VULN_OVERVIEW}
jq .vulnerabilities org_summary.json  | tr -d '\n' >> ${TEX_FILE_VULN_OVERVIEW}
echo "}{TOTAL}" >> ${TEX_FILE_VULN_OVERVIEW}
echo "\\end{center}" >> ${TEX_FILE_VULN_OVERVIEW}

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

echo -n "Found "
jq '. | length' ${FILE_INVENTORY}

#Display file inventory
#jq . ${FILE_INVENTORY}

echo ""
echo "--------------------------------"
echo "Get registry list"
echo "--------------------------------"
echo ""
mv ${FILE_REGISTRY_LIST} ${FILE_REGISTRY_LIST}.old 2>/dev/null
jq '.results | .[] | .registry' ${FILE_INVENTORY} |sort |uniq | sed 's/"//g' >${FILE_REGISTRY_LIST}

echo -n "Found "
cat ${FILE_REGISTRY_LIST} |wc -l

#Compute diff
diff -au ${FILE_REGISTRY_LIST}.old ${FILE_REGISTRY_LIST} |grep -E "^[+-]" >${FILE_REGISTRY_DIFF}
./diff2tex.sh ${FILE_REGISTRY_DIFF} >${TEX_REGISTRY_DIFF}

echo ""
echo "--------------------------------"
echo "Create alert reason table"
echo "--------------------------------"
echo ""

./cbc-alerts-reason.py ${CRED_ENTRY} |sort |uniq >alerts_reason.txt
cat alerts_reason.txt | awk '{$1=""; $2=""; sub(" ", " "); print}' |sort |uniq >reasons.txt

echo -n "Found "
cat reasons.txt |wc -l

rm -f ${TEX_FILE_ALERT_REASON}
while read -r reason; do
	echo -n "$reason & " |sed 's/malicious reputation/\\textbf{malicious reputation}/g' |sed 's/port scan/\\textbf{port scan}/g' >>${TEX_FILE_ALERT_REASON}
	grep -c "$reason" alerts_reason.txt |tr -d "\n"  >>${TEX_FILE_ALERT_REASON}
	echo " \\\\" >>${TEX_FILE_ALERT_REASON}
	echo "\\hline" >>${TEX_FILE_ALERT_REASON}
done < reasons.txt
echo "\\end{tabular}" >>${TEX_FILE_ALERT_REASON}


echo ""
echo "-----------------------------------"
echo "Create runtime alert severity table"
echo "-----------------------------------"
echo ""
# Low : 1-2
# Medium : 3,4,5
# High : 6.7,8
# Critical : 9.10
./cbc-runtime-alerts-severity.py ${CRED_ENTRY} >${FILE_RUNTIME_ALERTS}
LOW=$(( $(grep -c 1$ ${FILE_RUNTIME_ALERTS}) + $(grep -c 2 ${FILE_RUNTIME_ALERTS}) ))
MEDIUM=$(( $(grep -c 3 ${FILE_RUNTIME_ALERTS}) + $(grep -c 4 ${FILE_RUNTIME_ALERTS}) + $(grep -c 5 ${FILE_RUNTIME_ALERTS}) ))
HIGH=$(( $(grep -c 6 ${FILE_RUNTIME_ALERTS}) + $(grep -c 7 ${FILE_RUNTIME_ALERTS}) + $(grep -c 8 ${FILE_RUNTIME_ALERTS}) ))
CRITICAL=$(( $(grep -c 9 ${FILE_RUNTIME_ALERTS}) + $(grep -c 10 ${FILE_RUNTIME_ALERTS}) ))

echo "Found " ${LOW} " low runtime alerts(1,2)"
echo "Found " ${MEDIUM} " medium runtime alerts(3.4.5)"
echo "Found " ${HIGH} " high runtime alerts(6,7,8)"
echo "Found " ${CRITICAL} " critical runtime alerts(9,10)"

echo "\\nicevuln{${CRITICAL}}{CRITICAL}{VCRITICAL}" >${TEX_FILE_RUNTIME_ALERT}
echo "\\nicevuln{${HIGH}}{HIGH}{VHIGH}" >>${TEX_FILE_RUNTIME_ALERT} 
echo "\\nicevuln{${MEDIUM}}{MEDIUM}{VMEDIUM}" >>${TEX_FILE_RUNTIME_ALERT}
echo "\\nicevuln{${LOW}}{LOW}{VLOW}" >>${TEX_FILE_RUNTIME_ALERT}

./cbc-alerts-remoteip.py ${CRED_ENTRY} >alerts_remoteip.txt
if [ -s alerts_remoteip.txt ]; then
	echo "Connection to \textbf{malicious IP} :" >alertsremoteip.tex
	echo "\\begin{enumerate}" >>alertsremoteip.tex
	while read line; do echo "\\item $line" >>alertsremoteip.tex; done < alerts_remoteip.txt
	echo "\\end{enumerate}" >>alertsremoteip.tex
else
	echo "" >>alertsremoteip.tex
fi

./cbc-alerts-namespace.py |sort |uniq >alerts_namespace.txt
if [ -s alerts_namespace.txt ]; then
	echo "List of namespaces with high and critical runtime alerts :" >alertsnamespace.tex
	echo "\\begin{enumerate}" >>alertsnamespace.tex
	while read line; do echo "\\item $line" >>alertsnamespace.tex; done < alerts_namespace.txt
	echo "\\end{enumerate}" >>alertsnamespace.tex
else
	echo "" >>alertsnamespace.tex
fi


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

    echo -n "Found "
    jq '. | length' ${cluster}_${FILE_VULN_HISTORY}

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

#    jq . ${cluster}_${FILE_CRITICAL}


    jq .num_found ${cluster}_${FILE_CRITICAL} >${cluster}_critical.num_found.txt

    echo -n "Found "
    cat ${cluster}_critical.num_found.txt


    ./jsonvuln2tex.sh ${cluster}_${FILE_CRITICAL} >${cluster}_${TEX_FILE_CRITICAL} 
    echo -n "\\subsection{Kubernetes Cluster: ${cluster}}" >> ${TEX_FILE_CRITICAL}
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

#   jq . ${cluster}_${FILE_HIGH}

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

#    jq . ${cluster}_${FILE_DEPLOYED}
#	echo -n "Found "
#	jq '. | length' ${cluster}_${FILE_DEPLOYED}


	MALWARE_COUNT=$(jq '[ .results | .[] | select(.has_malware == true) ] | length' ${cluster}_${FILE_DEPLOYED})
	SECRET_COUNT=$(jq '[ .results | .[] | select(.has_secret == true) ] | length' ${cluster}_${FILE_DEPLOYED})

	echo "-------------------------------------------"
	echo "Get Malwares and secrets in deployed images"
	echo "-------------------------------------------"
	echo "Found ${MALWARE_COUNT} malwares"
	echo "Found ${SECRET_COUNT} secrets"

    	echo "\\subsection{Kubernetes Cluster: ${cluster}}" >> ${TEX_FILE_MALWARE}
	echo "\\nicevuln{${MALWARE_COUNT}}{Malware}{VHIGH}" >> ${TEX_FILE_MALWARE}
	echo "\\nicevuln{${SECRET_COUNT}}{Secret}{VMEDIUM}" >> ${TEX_FILE_MALWARE}
	echo "\\newline" >> ${TEX_FILE_MALWARE}

	if [ "${MALWARE_COUNT}" != "0" ]
	then
		echo "\\par" >> ${TEX_FILE_MALWARE}
		echo "Container images with malware:\\newline" >> ${TEX_FILE_MALWARE}
		jq '.results | .[] | select(.has_malware == true) | .full_tag' ${cluster}_${FILE_DEPLOYED} |sed -z 's/\"//g' |sed -z 's/\n/\\newline /g' >> ${TEX_FILE_MALWARE}
	fi

	if [ "${SECRET_COUNT}" != "0" ]
	then
		echo "\\vskip10pt" >> ${TEX_FILE_MALWARE}
		echo "\\par" >> ${TEX_FILE_MALWARE}
		echo "Container images with secret:\\par" >> ${TEX_FILE_MALWARE}
		jq '.results | .[] | select(.has_secret == true) | .full_tag' ${cluster}_${FILE_DEPLOYED} |sed -z 's/\"//g' |sed -z 's/\n/\\newline /g' >> ${TEX_FILE_MALWARE}
	fi

done < ${FILE_CLUSTER_LIST}

# Clean up
rm ${FILE_REQUEST}

# Replace "_" with "\textunderscore " in tex files
sed -i 's/\_/\\textunderscore /g' critical.tex
sed -i 's/\_/\\textunderscore /g' high.tex

exit 0 # End

