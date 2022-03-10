#!/usr/bin/env bash

# This scripts separates arguments into two groups
# based on the separator passed in $1. However, before proceeding
# we must use shift() bult-in function to remove that first argument
# and use the remaining arguments to do what the caller expects.
separator="$1"
shift
#
# After Successfully separating arguments into groups, it puts them into two variables:
# $args_before_separator and $arg_after_separator - declared as global - so that the script
# that sources this script would be able to use them.

declare -g args_before_separator
for arg in "${@}"; do
  if [[ "$arg" == "$separator" ]]; then break; fi
  args_before_separator="$args_before_separator $arg"
done

declare -g args_after_separator
for arg in "${@}"; do
  if [[ "$arg" == "$separator" ]]; then
    separator_reached="yes"
  elif [[ -n $separator_reached ]]; then
    args_before_separator="$args_before_separator $arg"
  fi
done
