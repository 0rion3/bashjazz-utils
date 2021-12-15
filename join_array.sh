join_array () {
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
