split_string() {

  OLDIFS=$IFS

  declare -ga split_string_out # returning an array through a variable
  echo $var_name
  str=$(printf "%q" "$1" | xargs) # %q makes it print as reusable output, -v writes into the $str variable

  delimiter=${2:-" "}
  if [ "$delimiter" == '\n' ]; then
    delimiter_name="NEWLINE"
    IFS=$'\n' read -rd '' -a split_string_out <<< "$str"
  else
    delimiter_name="$delimiter"
    IFS=$delimiter read -ra split_string_out <<< "$str"
  fi

  if [ "$3" == "--debug" ] || [ "$3" == "-d" ]; then
    echo --------------------------------------------
    echo DEBUG INFO from split_string
    echo Splitted into array using \'$delimiter_name\'
    echo --------------------------------------------
    for i in "${split_string_out[@]}"; do
      echo "  $i"
    done
    echo --------------------------------------------
  fi

  IFS=$OLDIFS

}
