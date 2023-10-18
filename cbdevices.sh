#!/bin/bash

source config.sh

FILE_DEVICES_CSV="devices.csv"
TEX_FILE_DEVICES_TARGETVALUES="devices_targetvalues.tex"
TEX_FILE_DEVICES_OS="devices_os.tex"
TEX_FILE_DEVICES_OS_VERSION="devices_os_version.tex"
TEX_FILE_DEVICES_SENSOR_VERSION="devices_sensor_version.tex"
TEX_FILE_DEVICES_SENSOR_OUTOFDATE="devices_sensor_outofdate.tex"
TEX_FILE_DEVICES_QUARANTINED="devices_quarantined.tex"

echo "Download active devices list"
curl -H X-Auth-Token:${TOKEN} https://api-${SERVER}.conferdeploy.net/appservices/v6/orgs/${ORG}/devices/_search/download?status=active >${FILE_DEVICES_CSV} 2>/dev/null

#####################################################################################################################

echo "--> Get Target values"
# Skip first line        get 6st column | remove ""
tail -n +2 ${FILE_DEVICES_CSV} | cut -f 6 -d ,  |  sed 's/"//g' >devices_tmp.txt

rm -f ${TEX_FILE_DEVICES_TARGETVALUES}
for level in LOW MEDIUM HIGH MISSION_CRITICAL
do
	echo -n "\\nicecounter{" >>${TEX_FILE_DEVICES_TARGETVALUES}
	grep -c ${level} devices_tmp.txt | tr -d '\n' >>${TEX_FILE_DEVICES_TARGETVALUES}
	#Remove the '_' in MISSION_CRITICAL as Tex doesn't like it !
	echo "}{${level//_/ }}" >>${TEX_FILE_DEVICES_TARGETVALUES}
done
rm -f devices_tmp.txt 
#####################################################################################################################

echo "--> Get OS type"
tail -n +2 ${FILE_DEVICES_CSV} | cut -f 13 -d ,  |  sed 's/"//g' >devices_type.txt

rm -f ${TEX_FILE_DEVICES_OS}
for os in WINDOWS MAC LINUX
do
	echo -n "\\nicecounter{" >>${TEX_FILE_DEVICES_OS}
	grep -c ${os} devices_type.txt | tr -d '\n' >>${TEX_FILE_DEVICES_OS}
	echo "}{${os}}" >>${TEX_FILE_DEVICES_OS}
done

#####################################################################################################################

echo "--> Get quarantined"
tail -n +2 ${FILE_DEVICES_CSV} | cut -f 25 -d ,  |  sed 's/"//g' >devices_quarantined.txt

rm -f ${TEX_FILE_DEVICES_QUARANTINED}
echo -n "\\nicecounter{" >>${TEX_FILE_DEVICES_QUARANTINED}
grep -c "true" devices_quarantined.txt | tr -d '\n' >>${TEX_FILE_DEVICES_QUARANTINED}
echo "}{Quarantined devices}" >>${TEX_FILE_DEVICES_QUARANTINED}

#####################################################################################################################

echo "--> Get sensors Out Of Date"
tail -n +2 ${FILE_DEVICES_CSV} | cut -f 27 -d ,  |  sed 's/"//g' >devices_outofdate.txt

rm -f ${TEX_FILE_DEVICES_SENSOR_OUTOFDATE}
echo -n "\\nicecounter{" >>${TEX_FILE_DEVICES_SENSOR_OUTOFDATE}
grep -c "true" devices_outofdate.txt | tr -d '\n' >>${TEX_FILE_DEVICES_SENSOR_OUTOFDATE}
echo "}{Sensors out of date}" >>${TEX_FILE_DEVICES_SENSOR_OUTOFDATE}

#####################################################################################################################
echo "--> Get Sensor version"

# Delete old files
rm -f ${TEX_FILE_DEVICES_SENSOR_VERSION}

#####################################################################################################################
echo "--> Get Sensor version : LINUX"
echo -E "\subsection{Linux sensors}" >>${TEX_FILE_DEVICES_SENSOR_VERSION}
tail -n +2 ${FILE_DEVICES_CSV} | grep LINUX | cut -f 17 -d ,  |  sed 's/"//g' >devices_sensorversion.txt
#TODO create horizontal barchart with all sensor versions, one barchart per OS type.
sort -rn devices_sensorversion.txt |uniq >devices_sensorversion_sorted.txt

#Remove blank lines
sed -i '/^$/d' devices_sensorversion_sorted.txt

# Compute height of bargraph
number_of_items=$(wc -l < devices_sensorversion_sorted.txt)
height=$((40 + 20 * number_of_items))

# [H] is to force the figure to be in line with the text
echo -E "\begin{figure}[H]"  >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo -E "\begin{tikzpicture}" >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo -E "\begin{axis}[" >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo "xbar," >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo "y axis line style = { opacity = 0 }," >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo "axis x line       = none," >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo "tickwidth         = 0pt," >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo "ytick             = data," >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo -E "width=0.7\textwidth," >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo "height=${height}pt," >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo -n "symbolic y coords = {" >>${TEX_FILE_DEVICES_SENSOR_VERSION}
cat devices_sensorversion_sorted.txt | tr '\n' ', ' >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo "}," >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo "nodes near coords" >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo "]" >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo -nE "\addplot coordinates { " >>${TEX_FILE_DEVICES_SENSOR_VERSION}
# Count number of occurence of the OS with grep -c of each OS
while read p; do
        echo -n "(" >>${TEX_FILE_DEVICES_SENSOR_VERSION}
        grep -c "$p" devices_sensorversion.txt | tr -d '\n' >>${TEX_FILE_DEVICES_SENSOR_VERSION}
	echo -n ",$p) " >>${TEX_FILE_DEVICES_SENSOR_VERSION}
done <devices_sensorversion_sorted.txt
echo -E "};" >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo -E "\end{axis}" >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo -E "\end{tikzpicture}" >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo -E "\caption{Linux sensor versions for active devices}" >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo -E "\end{figure}" >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo "" >>${TEX_FILE_DEVICES_SENSOR_VERSION}

#####################################################################################################################
echo "--> Get Sensor version : WINDOWS"
echo -E "\subsection{Windows sensors}" >>${TEX_FILE_DEVICES_SENSOR_VERSION}
tail -n +2 ${FILE_DEVICES_CSV} | grep WINDOWS | cut -f 17 -d ,  |  sed 's/"//g' >devices_sensorversion.txt
#TODO create horizontal barchart with all sensor versions, one barchart per OS type.
sort -rn devices_sensorversion.txt |uniq >devices_sensorversion_sorted.txt

#Remove blank lines
sed -i '/^$/d' devices_sensorversion_sorted.txt

# Compute height of bargraph
number_of_items=$(wc -l < devices_sensorversion_sorted.txt)
height=$((40 + 20 * number_of_items))

# [H] is to force the figure to be in line with the text
echo -E "\begin{figure}[H]"  >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo -E "\begin{tikzpicture}" >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo -E "\begin{axis}[" >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo "xbar," >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo "y axis line style = { opacity = 0 }," >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo "axis x line       = none," >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo "tickwidth         = 0pt," >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo "ytick             = data," >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo -E "width=0.7\textwidth," >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo "height=${height}pt," >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo -n "symbolic y coords = {" >>${TEX_FILE_DEVICES_SENSOR_VERSION}
cat devices_sensorversion_sorted.txt | tr '\n' ', ' >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo "}," >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo "nodes near coords" >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo "]" >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo -nE "\addplot coordinates { " >>${TEX_FILE_DEVICES_SENSOR_VERSION}

#while read p; do
#	echo "---"
#	grep -c "$p" devices_sensorversion.txt
#	echo "$p"
#done <devices_sensorversion_sorted.txt

# Count number of occurence of the OS with grep -c of each OS
while read p; do
        echo -n "(" >>${TEX_FILE_DEVICES_SENSOR_VERSION}
        grep -c "$p" devices_sensorversion.txt | tr -d '\n' >>${TEX_FILE_DEVICES_SENSOR_VERSION}
	echo -n ",$p) " >>${TEX_FILE_DEVICES_SENSOR_VERSION}
done <devices_sensorversion_sorted.txt
echo -E "};" >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo -E "\end{axis}" >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo -E "\end{tikzpicture}" >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo -E "\caption{Windows sensor versions for active devices}" >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo -E "\end{figure}" >>${TEX_FILE_DEVICES_SENSOR_VERSION}
echo "" >>${TEX_FILE_DEVICES_SENSOR_VERSION}

# TODO : MAC

#####################################################################################################################
echo "--> Get  OS version"
# Add Windows before Server for 2008 and 2012 for consistancy in OS names
sed -i 's/Server\ 2008/Windows\ Server\ 2008/g' ${FILE_DEVICES_CSV}
sed -i 's/Server\ 2012/Windows\ Server\ 2012/g' ${FILE_DEVICES_CSV}

tail -n +2 ${FILE_DEVICES_CSV} | cut -f 16 -d ,  |  sed 's/"//g' >devices_osversion.txt

# Reverse sort, as they will start from bottom on Y axis.
sort -r devices_osversion.txt |uniq >devices_osversion_sorted.txt

#Remove blank lines
sed -i '/^$/d' devices_osversion_sorted.txt

# Compute height of bargraph
number_of_items=$(wc -l < devices_osversion_sorted.txt)
height=$((40 + 20 * number_of_items))

# [H] is to force the figure to be in line with the text
echo -E "\begin{figure}[H]"  >${TEX_FILE_DEVICES_OS_VERSION}
echo -E "\begin{tikzpicture}" >>${TEX_FILE_DEVICES_OS_VERSION}
echo -E "\begin{axis}[" >>${TEX_FILE_DEVICES_OS_VERSION}
echo "xbar," >>${TEX_FILE_DEVICES_OS_VERSION}
echo "y axis line style = { opacity = 0 }," >>${TEX_FILE_DEVICES_OS_VERSION}
echo "axis x line       = none," >>${TEX_FILE_DEVICES_OS_VERSION}
echo "tickwidth         = 0pt," >>${TEX_FILE_DEVICES_OS_VERSION}
echo "ytick             = data," >>${TEX_FILE_DEVICES_OS_VERSION}
echo -E "width=0.7\textwidth," >>${TEX_FILE_DEVICES_OS_VERSION}
echo "height=${height}pt," >>${TEX_FILE_DEVICES_OS_VERSION}
echo -n "symbolic y coords = {" >>${TEX_FILE_DEVICES_OS_VERSION}
cat devices_osversion_sorted.txt | tr '\n' ', ' >>${TEX_FILE_DEVICES_OS_VERSION}
echo "}," >>${TEX_FILE_DEVICES_OS_VERSION}
echo "nodes near coords" >>${TEX_FILE_DEVICES_OS_VERSION}
echo "]" >>${TEX_FILE_DEVICES_OS_VERSION}
echo -nE "\addplot coordinates { " >>${TEX_FILE_DEVICES_OS_VERSION}
# Count number of occurence of the OS with grep -c of each OS
while read p; do
        echo -n "(" >>${TEX_FILE_DEVICES_OS_VERSION}
        grep -c "$p" devices_osversion.txt | tr -d '\n' >>${TEX_FILE_DEVICES_OS_VERSION}
	echo -n ",$p) " >>${TEX_FILE_DEVICES_OS_VERSION}
done <devices_osversion_sorted.txt
echo -E "};" >>${TEX_FILE_DEVICES_OS_VERSION}
echo -E "\end{axis}" >>${TEX_FILE_DEVICES_OS_VERSION}
echo -E "\end{tikzpicture}" >>${TEX_FILE_DEVICES_OS_VERSION}
echo -E "\caption{OS versions for active devices}" >>${TEX_FILE_DEVICES_OS_VERSION}
echo -E "\end{figure}" >>${TEX_FILE_DEVICES_OS_VERSION}
echo "" >>${TEX_FILE_DEVICES_OS_VERSION}

exit 0 # End

