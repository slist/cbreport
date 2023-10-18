#!/bin/bash

AUTHOR=$(getent passwd | grep "$USER" | cut -d":" -f5 | cut -d"," -f1)

echo "\\author{${AUTHOR}}" >author.tex

