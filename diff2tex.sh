#!/bin/bash

# This script will convert a diff file to a colored tex file
# In a diff files are starting with the character'+' or '-'

if [ -z "$1" ]
  then
    echo "Error: No argument supplied"
    echo ""
    echo "Syntax: $0 <diff filename>"
    exit -1 # No arg
fi

if [ ! -f "$1" ]; then
    echo "File $1 does not exist."
    exit -1 # File does not exist
fi


while read line;
do
	#Replace _ by \_
	line=${line//_/\\_}

	#Replace --- by -\/-\/- to avoid ligature in Latex
	line=${line//---/-\\/-\\/-}

	if [[ $line == +* ]];
	then
		echo "\\textcolor{blue}{$line}\\\\"
	else
		echo "\\textcolor{red}{$line}\\\\"
	fi
done < $1

exit 0 # End

#Convert character to escaped charecter for Latex:
            "#"=>"\\#",
            "$"=>"\\$",
            "%"=>"\\%",
            "&"=>"\\&",
            "~"=>"\\~{}",
            "_"=>"\\_",
            "^"=>"\\^{}",
            "\\"=>"\\textbackslash",
            "{"=>"\\{",
            "}"=>"\\}",


