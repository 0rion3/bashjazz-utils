# If we don't set these the lastpipe, we're going to have issues with setting
# the global variables when the input is passed through a pipe. It's going to be a subprocess
# and the main process isn't waiting for it's caller to finish. So we set the variables alright
# with declare -g, but they might not be set in time the parent process is about to use
# them and, therefore, they're going to be empty.
shopt -s lastpipe
source $SHARED_SCRIPTS_PATH/utils/split_string_pipe.sh

assign_vars_from_out () {
  while read line; do
    if [[ $line =~ ^[a-zA-Z_][a-zA-Z0-9_]+=.*$ ]]; then
      echo $line | split_string '=' --varname=arr
      key=${arr[0]}
      value=$(echo ${arr[1]} | sed -r "s/(['|\"]?)(.+)\1/\2/")
      declare -g "$key"="$value"
    fi
  done
}
