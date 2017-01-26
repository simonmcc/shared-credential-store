#!/bin/bash
#
# Encrypt a file so that all of us can decrypt it

TEAM_KEYS="$(ls team-gpg-public-keys/ | tr '\n' ' ')"

gpg -a --yes --trust-mode always --batch --group TEAM_KEYS="$TEAM_KEYS" -r TEAM_KEYS  --encrypt $1
