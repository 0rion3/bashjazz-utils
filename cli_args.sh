#!/usr/bin/env bash
source $BASHJAZZ_PATH/utils/array.sh

# WARNING: this script does not support whitespace in argument values
# BUT it will remove the double and single quotes just in case.
declare -gA NAMED_ARGS=()
declare -ga POSITIONAL_ARGS=()

CliArgs() {

  local ARG_VALUE_TRUE="${ARG_VALUE_TRUE:-yes}"
  local ARG_VALUE_FALSE="${ARG_VALUE_FALSE:-no}"

  if [[ "$@" == *"--value-required-args="* ]]; then
    local VALUE_REQUIRED_ARGS=(
      $(echo "$@" | grep -oE '\-\-value-required-args=[^ ]+' | sed -E 's/.+=//' | sed 's/,/ /g')
    )
  fi
  if [[ "$@" == *"--valueless-args="* ]]; then
    local VALUELESS_ARGS=(
      $(echo "$@" | grep -oE '\-\-valueless-args=[^ ]+' | sed -E 's/.+=//' | sed 's/,/ /g')
    )
  fi

  if [[ -n "${VALUE_REQUIRED_ARGS[@]}" ]]; then shift; fi
  if [[ -n "${VALUELESS_ARGS[@]}" ]];      then shift; fi

  local one_dash_arg_name

  for arg in "${@}"; do

    # Two-dash arguments - it's a long argument with the value being provided
    # after the "=" character or assigned from $ARG_TRUE_VALUE (just because of
    # this argument's mere presence).

    if [[ "$arg" == "--"* ]]; then
      # Remove the two leading dashes, replace = with a space so we can convert an argument
      # into a two item-array where the 1st item is the name of the argument and the 2nd argument
      # is its value.
      arg_name="$(echo "$arg" | grep -oE '\-\-[a-z][a-z0-9\-]+' | sed 's/^--//')"

      local arg_allowed="$(
        Array_contains $arg_name "${VALUE_REQUIRED_ARGS[@]}" || \
        Array_contains $arg_name ${VALUELESS_ARGS[@]}
      )"

      if [[ -z "$arg_allowed" ]]; then
        echo "  Bad argument: $arg_name"
        exit 1
      fi

      if [[ -n "$(Array_contains $arg_name ${VALUE_REQUIRED_ARGS[@]})" ]]; then
        arg_value="$(echo "$arg" | grep -voE '\-\-[a-z0-9]=')"
        NAMED_ARGS["$arg_name"]="$arg_value"
      elif [[ -n "$(Array_contains $arg_name ${VALUELESS_ARGS[@]})" ]]; then
        NAMED_ARGS["$arg_name"]="$ARG_VALUE_TRUE"
      else
        echo "  Bad argument: --$arg_name"
        exit 1
      fi

    # One dash arguments such as `-c` can also require value, but,
    # technically, the value for such an argument would be a separate item
    # in the $@ array - the next item after the on-dash argument itself. Or,
    # alternatively, if the one-dash argument is immediately followed by
    # by a number, such as it would be in `tail -n1`, we use that number
    elif [[ $arg == "-"* ]]; then

      arg_name="$(echo "$arg" | grep -oE '[a-zA-Z]' )"

      local arg_allowed="$(
        Array_contains $arg_name ${VALUE_REQUIRED_ARGS[@]} || \
        Array_contains $arg_name ${VALUELESS_ARGS[@]}
      )"

      if [[ -z "$arg_allowed" ]]; then
        echo "  Bad argument: $arg_name"
        exit 1
      fi

      arg_value="$(echo "$arg" | grep -Eo '[0-9]+$')"

      if [[ -n "$(Array_contains $arg_name ${VALUE_REQUIRED_ARGS[@]})" ]]; then 
        if [[ -n "$arg_value" ]]; then
          NAMED_ARGS[$arg_name]="$arg_name"
        else
          one_dash_arg_name="$arg_name"
        fi
      else
        NAMED_ARGS[$arg_name]="$ARG_VALUE_TRUE"
      fi

    # Adding value for the one_dash _argument.
    elif [[ -n "$one_dash_arg_name" ]]; then
      NAMED_ARGS[$one_dash_arg_name]="$arg"
      unset one_dash_arg_name
    # Everything else is considered a positional argument
    else
      POSITIONAL_ARGS+=("$arg")
    fi

  done

}

CliArgs $@
