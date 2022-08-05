#!/usr/bin/env bash
source $BASHJAZZ_PATH/utils/colors.sh

# 📗 --- ▼ --- FORMATTING (COLOR AND INDENTATION) FUNCTIONS -------------- ▼ ---

  # Prints in number of spaces specified in $1 any given line
  # (not every line) with a space or another character that may be optionally
  # provided in $2.
  ind() {
    i=1; num=$1; str=${2:-"­"}
    while [ $i -le $num ]; do
      indentation="$indentation$str"
      ((i++))
    done
    echo -n "$indentation"
  }

  # Prints several newline characters specified in $1
  nl() {
    echo -n "$(ind $1 '\n')"
  }

  # Colorizes a given string (but does not remove colorization)
  # with color names from $BASHJAZZ/utils/colors.sh, only you can use
  # snake_case for their names. Don't forget to reset the formatting
  # by calling `nof` or `color off`.
  color() {
    color=$1
    if [[ "$1" =~ ^(off|no|0)$ ]]; then
      color=$Color_Off
    else
      # Capitalize the first letter in every word of the snake_cased string,
      # since that's how colors are named in ./colors.sh
      color="$(echo "$1" | sed -r 's/(^|_)([a-z])/\1\U\2/g')"
      color="${!color}"
    fi
    echo -n "$color"
  }

  # 🎭 ALIAS TO `color()`. Not to confuse with "Clear" or any other meaning,
  # this stands short for color. A short synonym for `color`. Can later be
  # removed if any conflicts are found.
  clr() {
    color ${@}
  }

  # 🎭 ALIAS TO `color off`, because it's shorter.
  nof() {
    color off
  }

# 🏁 --- ▲ --- END OF colorizing functions ------------------------------ ▲ ---

# 📗 --- ▼ --- HELPER FUNCTIONS ----------------------------------------- ▼ ---
#
  exec_command_chain() {
    IFS=';' read -ra commands <<< "$1"
    for c in "${commands[@]}"; do
      commands_out="$commands_out$(eval "$c")"
    done
    echo -n "$commands_out"
  }

  wrap() {
    # $format, $prefix and $suffix are always function name(s) with arguments
    # Function names are separated by ';' so we can basically call eval()
    # and that'll work.
    #
    # 🚩 ATTENTION!!!  Because this function uses `eval()` on its
    # arguments. Careful, don't let any unwanted third-party Not sure if it's
    # important, since IT IS NOT using eval() on the content of what's being
    # formatted, but still - be careful.

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

# 🏁 --- ▲ ---- END OF formatting (color and indentation) functions ------ ▼ ---
