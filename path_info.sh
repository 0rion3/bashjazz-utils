# A collection of functions to extract certain parts of filename or directory
# path fro the path given. For now just two functions, some more should probably
# be added.

extract_path_without_name() {
  echo "$1" | sed -r 's|(.+)/[^/]+$/.*$|\1|'
}

# gets everything after the last forward slash / - meaning file|dir name + wildcard 
extract_only_name_from_path() {
  echo "$1" | sed -r 's|^(.+/)||'
}
