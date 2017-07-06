#!/usr/bin/env bash
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

echo "Run JavaScript Auto Format"
# Get the JS files that were just changed
js_files=$(git diff --cached --name-only --diff-filter=ACM | grep "\.jsx\|\.js\?$")
# If we have some, then
if [ -n "$js_files" ]; then
  # get the local install of esformatter
  esformatter="CheckoutWebApplication/node_modules/.bin/esformatter"

  # for each of the changed files, run them through esformatter
  for file in $js_files; do
	#Get the file created time in epoch second to compare
    created_time=$(git log --follow --format=%at --reverse -- $file| head -1)
    #Check if the changed file is new or created after the hook agreement
    if [ $(( created_time > hook_start_time )) = 1 ] || [ -z "$created_time" ]; then
        $esformatter -i $file
        # then detect if they've changed.
        if [ -n "$(git diff --name-only --diff-filter=M $file)" ]; then
          # If they have, we know they weren't formatted correctly
          js_dirty=true
        fi
    fi
  done

  # if there were files that weren't formatted correctly, exit with an error
  # code and display the following message
  if [ "$js_dirty" = true ]; then
    tput setaf 1
    echo -e "${BLUE}AUTO-FORMATTER:${NC} Changed JavaScript files did not adhere to formatting rules and so have been
reformatted automatically. Please review these changes and then add them to
your previous commit with:"
    echo -e "${BOLD}git commit --amend --no-edit${NORMAL}"
    exit 1
  fi
fi
