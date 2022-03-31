#!/usr/bin/env bash
#
# A collection of functions to extract certain parts of filename or directory
# path from the path given. For now just two functions, some more should probably
# be added.

PathSection_name() {
  echo "$1" | sed -r 's|^(.+/)||'
}

PathSection_before_name() {
  echo "$1" | sed -r 's|(.+)/[^/]+$/.*$|\1|'
}
