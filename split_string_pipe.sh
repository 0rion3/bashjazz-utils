source $BASHJAZZ_PATH/utils/join_array.sh

# If we don't set these the lastpipe, we're going to have issues with setting
# the global variables when the input is passed through a pipe. It's going to be a subprocess
# and the main process isn't waiting for it's caller to finish. So we set the variables alright
# with declare -g, but they might not be set in time the parent process is about to use
# them and, therefore, they're going to be empty.
shopt -s lastpipe

split_string () {

  OLDIFS=$IFS

  delimiter=${1:-" "}

  if [[ $2 =~ ^--varname= ]]; then
    varname=$(echo "$2" | sed -r 's/^--varname=//')
  else
    joiner=$(printf "$2")
    joiner=${joiner:-'\n'}
  fi

  lines=""
  while read line; do
    lines="$lines$line"
  done

  IFS=$delimiter arr=( $lines )

  if [[ -n $joiner ]]; then
    if [[ $joiner == '\n' ]]; then joiner="NEWLINE"; fi
    result=$(join_array $arr $joiner)
  else
    declare -ga "$varname"=$arr
  fi

  if [ "$3" == "--debug" ] || [ "$3" == "-d" ]; then
    echo "--------------------------------------------"
    echo "DEBUG INFO from split_string"
    if [[ -n $varname ]]; then
      echo "Splitted into array '$varname' using '$delimiter'"
      echo "--------------------------------------------"
      for i in "${arr[@]}"; do
        echo "  $i"
      done
    else
      echo "Splitted into array using '$delimiter' and then joined using '$joiner'"
    fi
    echo "--------------------------------------------"
  fi

  [[ -n $joiner ]] && echo -e $result

  IFS=$OLDIFS

}
