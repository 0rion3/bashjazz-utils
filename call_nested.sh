#!/usr/bin/env bash

# This small library removes the boilerplate code to be able to
# implement name-spacing in Bash through nested functions.

# Suppose we wrote the following code:
#
#    source $BASHJAZZ_PATH/utils/call_nested.sh
#    # ----------- below are our name-spaced functions -----------
#    Talk() {
#      local subject="$@"
#      hello()   { echo -n "hello and..."  }
#      goodbye() { echo "goodbye $subject" }
#      all()     { hello && goodbye        }
#    call_nested --all $@ }
#
# There are two ways to use it:
#
# 1. By calling it with the --all argument (must come first) and then optionally
#    passing the rest of them as $@ or.
#
#    ATTENTION:
#       DO NOT be using `call_nested all` because while on the surface it
#       may work, it'll break the argument order and shifting functionality.
#
#    USAGE EXAMPLE:
#        Talk --all            # => prints "hello and... goodbye"
#        Talk --all my friend  # => prints "hello and... goodbye my friend"
#
# 2. By being selective as to which nested function to call, passing the name
#    of that function in the first argument
#
#    USAGE EXAMPLE:
#
#        Talk hello           # => prints "hello and... "
#        Talk goodbye darling # => prints "goodbye darling"
#
#
# This allows us to avoid the cryptic boilerplate code (even if minimal), while
# also introducing an option to run ALL of the nested functions. The --all flag
# actually runs the all() function, which may or may not exist. If it doesn't,
# it will exit with an error.
#
# It is recommended that the calls inside the all() function be chained with &&
# so that the program would not continue unless there's an error in one of the
# calls.

call_nested() {

  local mainf=$1
  local nestedf=$2

  if [[ "$nestedf" == "--all" ]]; then
    shift 2
    $mainf all $@
  else
    shift 1
    $mainf $@
  fi

}
