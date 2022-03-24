#!/usr/bin/env bash
#
############## URL DECODING FUNCTIONS ##############
# Encode/decode urls so you can feed them to curl.
# Credit both functions goes to all the contributors to this gist: https://gist.github.com/cdown/1163649
#
# Slightly changed it due to the fact that it encodes = characters, which might
# not be a good idea if you're sending a request through curl.
#
urlencode() {
  local length="${#1}"

  excludes=$(echo "$2" | sed -r 's/^exclude://')
  regexp='^[a-zA-Z0-9]$' # Here we want to be careful with ranges, so all the special chars,
                           # will be checked as a separate non-regexp condition.

  for (( i = 0; i < length; i++ )); do
    local c="${1:i:1}"
    if [ $(echo "$c" | grep -E "$regexp") ] || [[ "$excludes" == *"$c"* ]]; then
      printf "$c"
    elif [[ $c == '%' ]]; then
      printf '\x25'
    else
      printf "$c" | xxd -p -c1 | while read x; do printf "%%%s" "$x"; done
    fi
  done
}
#
urldecode() {
  local url_encoded="${1//+/ }"
  printf '%b' "${url_encoded//%/\\x}"
}
############## END URL DECODING FUNCTIONS ###############
