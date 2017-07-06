#!/usr/bin/env bash
dirty_status=0
# Date in epoch second when hooks are enforced
hook_start_time=1499267699

echo "Run JavaScript Lint for V2"
files_to_lint=$(git diff --cached --name-only --diff-filter=ACM | grep "js/v2" | grep "\.jsx\|\.js\?$")
if [ -n "$files_to_lint" ]; then
  eslint="CheckoutWebApplication/node_modules/.bin/eslint"

  for file in $files_to_lint; do
      echo "JavaScript linting $file..."
      $eslint -c ./CheckoutWebApplication/.eslintrc --fix $file
      # Capture the return code of JSHint, so we can exit with the proper code
      # after we've linted all the files.
      return_code=$?
      if [[ $return_code != 0 ]]; then
        dirty_status=1
      fi
  done
  exit $dirty_status
fi

echo "Run JavaScript Lint for the Rest"
files_to_lint=$(git diff --cached --name-only --diff-filter=ACM | grep -v "js/v2" | grep "\.jsx\|\.js\?$")
if [ -n "$files_to_lint" ]; then
  eslint="CheckoutWebApplication/node_modules/.bin/eslint"

  for file in $files_to_lint; do
	#Get the file created time in epoch second to compare
    created_time=$(git log --follow --format=%at --reverse -- $file| head -1)
    #Check if the changed file is new or created after the hook agreement
    if [ $(( created_time > hook_start_time )) = 1 ] || [ -z "$created_time" ]; then
      echo "JavaScript linting $file..."
      $eslint -c ./CheckoutWebApplication/.eslintrc --fix $file
      # Capture the return code of JSHint, so we can exit with the proper code
      # after we've linted all the files.
      return_code=$?
      if [[ $return_code != 0 ]]; then
        dirty_status=1
      fi
     fi
  done
  exit $dirty_status
fi
