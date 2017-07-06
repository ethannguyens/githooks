#!/usr/bin/env bash

dirty_status=0
# Date in epoch second when hooks are enforced
hook_start_time=1499267699

echo "Run SCSS Lint"
files_to_lint=$(git diff --cached --name-only --diff-filter=ACM | grep "\.scss$")
if [ -n "$files_to_lint" ]; then
  stylelint="CheckoutWebApplication/node_modules/.bin/stylelint"

  for file in $files_to_lint; do
	#Get the file created time in epoch second to compare
    created_time=$(git log --follow --format=%at --reverse -- $file| head -1)
    #Check if the changed file is new or created after the hook agreement
    if [ $(( created_time > hook_start_time )) = 1 ] || [ -z "$created_time" ]; then
        echo "SCSS linting $file..."
        $stylelint -c CheckoutWebApplication/.eslintrc --fix --syntax scss $file
        # Capture the return code of stylelint, so we can exit with the proper code
        # after we've linted all the files.
        return_code=$?
        echo "Exited with code $return_code"
        if [[ $return_code != 0 ]]; then
          dirty_status=1
        fi
    fi
  done
  exit $dirty_status
fi
