#!/bin/bash
#
# Import keys for all team members

TOP=`dirname $0`
FILES=`find $TOP/team-gpg-public-keys/ -type f`

for file in $FILES; do
    gpg --import $file
done
