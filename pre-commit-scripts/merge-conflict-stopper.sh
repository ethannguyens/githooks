#!/usr/bin/env bash

RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "Run Merge Conflict Stopper"

changed=$(git diff --cached --name-only)

if [[ -z "$changed" ]]
then
  exit 0
fi

echo $changed | xargs egrep '[><]{7}' -H -I --line-number

## If the egrep command has any hits - echo a warning and exit with non-zero status.
if [ $? == 0 ]
then
  printf "\n\n${RED}WARNING: You have merge markers in the above files, lines. Fix them before committing.${NC}\n\n"
  exit 1
fi
