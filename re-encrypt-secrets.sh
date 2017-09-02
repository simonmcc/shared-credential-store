#!/bin/bash
#
# Re-Encrypt all files

TOP=`dirname $0`
FILES=`find $TOP -name "*.asc" -or -name "*.gpg"`

# if there isn't a gpg-agent running, launch one
if [ -z "${GPG_AGENT_INFO}" ]; then
  eval $(gpg-agent --daemon --sh)
  echo "Agent started: GPG_AGENT_INFO=${GPG_AGENT_INFO}"

  # Sign an empty file so that the gpg-agent has the key passphrase
  tempfoo=credentials-common
  SIGNFILE=`mktemp /tmp/${tempfoo}.XXXXXX` || exit 1
  # use a team-member public key to test
  RECIPIENT="$(ls team-gpg-public-keys | head -1)"
  gpg --use-agent --encrypt -r ${RECIPIENT} $SIGNFILE
  rm $SIGNFILE
else
  echo "Existing gpg-agent found: GPG_AGENT_INFO=${GPG_AGENT_INFO}"
fi


for file in $FILES; do
	# decrypt the secret
	SECRET="$(gpg --batch --use-agent --logger-file /dev/null --decrypt -o - ${TOP}/${file})"

  if [ -n "${SECRET}" ]; then
    # we have decrypted something, re-encrypt it
    echo "${SECRET}" | ./encrypt.sh - > ${TOP}/${file}
  else
    echo "ERROR: Tried to decrypt ${TOP}/${file} and failed!"
  fi
done
