#!/usr/bin/env bash

source $BASHJAZZ_PATH/utils/colors.sh

ind() {
  i=1; num=$1; str=${2:-"­"} # SOFT HYPHEN U+00AD is used an invisible space
  while [ $i -le $num ]; do
    indentation="$indentation$str"
    ((i++))
  done
  echo -n "$indentation"
}

nl() {
  echo -n "$(ind $1 '\n')"
}

color() {
  color=$1
  if [[ "$color" =~ ^(off|no|0)$ ]]; then
    color=$Color_Off
  else
  #
  # capitalize the first letter in every word of the snake_cased string,
  # since that's how colors are named in ./colors.sh
    color="$(echo "$1" | sed -r 's/(^|_)([a-z])/\1\U\2/g')"
    color="${!color}"
  fi
  echo -n "$color"
}
# Not to confuse with "Clear" or any other meaning, this stands short
# for color. A short synonym for `color`. Can later be removed if any conflicts
# are found.
clr() {
  clr ${@}
}
# An alias for `color off`, because you don't want to type all that.
nof() { color off }

wrap() {
  # $format, $prefix and $suffix are always function name(s) with arguments
  # Function names are separated by ';' so we cal basically call eval() and that'll work
  #
  # ATTENTION!!!
  # This function uses eval() on its arguments. Careful, don't let any unwanted third-party
  # Not sure if it's important, since IT IS NOT using eval() on the content of
  # what's being formatted, but still - be careful.

  format="$(exec_command_chain "$2")"
  prefix="$(exec_command_chain "$3")"
  suffix="$(exec_command_chain "$4")"

  # Let's trim all whitespace at the beginning of the line by default
  content="$(echo "$1" | sed "s/^\s*//")"
  #
  content="$(echo "$content" | sed -r "s/^((\s*\S+\s*)+)$/$prefix\1/g")"
  content="$(echo "$content" | sed -r "s/^((\s*\S+\s*)+)$/\1$suffix/g")"
  echo "$format$content$(color off)"
}


# Helper functions

exec_command_chain() {
  IFS=';' read -ra commands <<< "$1"
  for c in "${commands[@]}"; do
    commands_out="$commands_out$(eval "$c")"
  done
  echo -n "$commands_out"
}
