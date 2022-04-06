#!/usr/bin/env bash

# WARNING: this code does not support whitespace in argument values
# BUT it will remove the double and single quotes just in case.

default_value="${1:-true}"

declare -gA long_cli_args
for arg in "${@}"; do
  # If we see two dashes, then it's a long argument
  # It's a long argument with the value being provided after the = character.
  if [[ $arg =~ ^\-\-[a-z0-9\-]+(=[^\s])?$ ]]; then
    # Remove the two leading dashes, replace = with a space so we can convert an argument
    # into a two item-array where the 1st item is the name of the argument and the 2nd argument
    # is its value.
    arg_arr=( $(echo $arg | sed 's/^--//' | sed 's/=/ /g') )
    # Unlike cli-arguments, the variables must not contain - character, so
    # we take care of that before we convert strings with arg names into actual variables.
    #
    arg_name="$(echo "${arg_arr[0]}" | sed 's/-/_/g')"
    arg_value="$(echo "${arg_arr[1]}" | sed "s/[\"']//g")"
    long_cli_args["$arg_name"]="${arg_value:-yes}"
  fi
done

# Remove long arguments starting with two --two-dashes from $@.
for arg in "${@}"; do
  shift
  if [[ "$arg" != "--"* ]]; then
    set -- "$@" "$arg"
  fi
done
