#!/bin/bash
#
# An easy way to capture the output of the command and reuse it
#
# Credits go to: StackOverflow user Connor, solution borrowed from here:
#   https://stackoverflow.com/questions/24283097/reusing-output-from-last-command-in-bash 
#
# I've added deleting the file for privacy reasons

cap () { tee /tmp/capture_$BASHPID.out; }

ret () {
  out="$(cat /tmp/capture_$BASHPID.out)"
  rm /tmp/capture_$BASHPID.out
  echo "$out"
}
