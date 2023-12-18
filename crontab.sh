#!/bin/bash

# Create a monthly report

#     m h dom mon dow   command

line="0 0  1   *   *    cd $(pwd); make; cp cbreport.pdf cbreport\$(date -I).pdf"

(crontab -u $(whoami) -l; echo "$line" ) | crontab -u $(whoami) -
