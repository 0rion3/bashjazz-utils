#!/usr/bin/env bash

#source $BASHJAZZ_PATH/utils/assign_vars_from_out.sh

parse_long_args() {
  local arguments_as_string=""
  for arg in ${@}; do
    # Remove the two leading dashes, replace = with a space so we can convert an argument
    # into a two item-array where the 1st item is the name of the argument and the 2nd argument
    # is its value.
    arg_arr=( $(echo $arg | sed 's/^--//' | sed 's/=/ /g') )
    # Unlike cli-arguments, the variables must not contain - character, so
    # we take care of that before we convert strings with arg names into actual variables.
    #
    arg_name="$(echo "${arg_arr[0]}" | sed 's/-/_/g')"
    # TODO: doesn't support spaces in argument values
    # BUT it will remove the double and single quotes just in case.
    arg_value="$(echo "${arg_arr[1]}" | sed "s/[\"']//g")"
    arguments_as_string="$arguments_as_string$arg_name=$arg_value\n"
  done
  echo -e "$arguments_as_string" | assign_vars_from_out
}
