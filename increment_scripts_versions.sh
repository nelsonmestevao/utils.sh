#!/usr/bin/env bash

increment_version() {
  local delimiter=.
  local array=("$(echo "$1" | tr $delimiter '\n')")
  array[$2]=$((array[$2]+1))
  echo "$(local IFS=$delimiter ; echo "${array[*]}")"
}

increment_version $1 $2
