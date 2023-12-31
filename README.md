# cbreport

# Install a few packages on Ubuntu 22.04 LTS.

``` sh
sudo apt update -y
sudo apt install -y make git pip wget curl unzip xpdf python3
sudo apt install -y texlive-latex-base texlive-latex-extra texlive-fonts-recommended texlive-fonts-extra texlive-bibtex-extra texlive-binaries texstudio texlive-full
```

# Download Metropolis font
``` sh
wget https://www.1001fonts.com/download/metropolis.zip
mkdir metropolis
unzip -d metropolis metropolis.zip
```

# Install Metropolis font in Ubuntu
``` sh
sudo cp -a metropolis /usr/share/fonts/opentype/
sudo fc-cache -f -v
```

# Clone cbreport
``` sh
git clone https://github.com/slist/cbreport
cd cbreport
```

Edit the file cbreport.tex with your "Organization name".

# Install or Update CBC python SDK
## Install CBC Python SDK
``` sh
pip install carbon-black-cloud-sdk
```

## Update CBC Python SDK
Or Update CBC SDK

``` sh
pip install -U carbon-black-cloud-sdk
```

# API Keys

In your browser, in Carbon Black Cloud Console, create an API  with READ access on all parameters:
1. In Settings / Access Levels, push the "Add Access Level" button to create a new access level
1. Name this new access level "Read All", click on all bold "READ" checkboxes, and push "Save" button.
1. In Settings / API Keys, push the "Add API Key" button to create a new API Key
1. Name this new API Key "Report API", select "Custom" Access Level Type", and select the "Real All" Custom Access Level, and push "Save" button.
1. Copy credentials (API ID and API Secret Key) and "Org Key" in a "credentials.cbc" file (See format below).

# Credentials

Create a file ~/.carbonblack/credentials.cbc

``` sh
mkdir ~/.carbonblack/
touch ~/.carbonblack/credentials.cbc
```

Edit this file to add your API key, for example:

in US:

``` sh
[default]
url=https://defense-prod05.conferdeploy.net
token=ABCDEFGHIJKLMNO123456789/ABCD123456
org_key=ABCD123456
ssl_verify=false
ssl_verify_hostname=no
```

in Europe:
``` sh
[default]
url=https://defense-eu.conferdeploy.net
token=ABCDEFGHIJKLMNO123456789/ABCD123456
org_key=ABCD123456
ssl_verify=false
ssl_verify_hostname=no
```

# Create the report

By default, the Makefile will use the CB org called "default" in ~/.carbonblack/credentials.cbc.

``` sh
make
```
# Diff

Each time, you generate a report, a diff with the previous report is generated.

To remove all files, you can use 'make clean', no diff will be generated next time.

# Generate a report every month
To add a line in crontab to generate the report every month, you can run:
``` sh
make crontab
```
# Thank You!
Thank You, and Congratulations if you have setup this automatic report generation successfully!
