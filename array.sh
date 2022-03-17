#!/usr/bin/env bash

# $1 is value it's looking for, $2 is arrays passed as string.
# Example:
#
#   $ Array_contains "hello" "${arr[@]}"
#
Array_contains() {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && echo "$e" && return 0; done
  return 1
}

Array_join() {
  arr=$1
  joiner=$2
  if [[ $joiner == "NEWLINE" ]]; then
    str=""
    for i in ${arr[@]}; do
      str="$str$i\n"
    done
    echo -e $(echo $str | sed -z '$ s/\n$//')
  else
    OLDIFS=$IFS
    printf '%s\n' "$((IFS="⁋"; printf '%s' "${arr[*]}") | sed "s,⁋,$joiner,g"))"
    IFS=$OLDIFS
  fi
}
