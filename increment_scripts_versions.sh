#!/usr/bin/env bash

get_version() {
  local file="$1"
  grep "display_version " "$file" | grep -o "[0-9]\.[0-9]\.[0-9]"
}

increment_version() {
  local -r current_version=$1

  local major=$(echo "$current_version" | cut -d'.' -f 1)
  local minor=$(echo "$current_version" | cut -d'.' -f 2)
  local patch=$(echo "$current_version" | cut -d'.' -f 3)

  if [ -z "${major}" ] || [ -z "${minor}" ] || [ -z "${patch}" ]; then
    echo "VERSION <$major>.<$minor>.<$patch> is bad set or set to the empty string"
    exit 1
  fi

  case ${2:-patch} in
    major)
      ((major++))
      minor=0
      patch=0
      ;;

    minor)
      ((minor++))
      patch=0
      ;;

    patch)
      ((patch++))
      ;;
  esac

  echo "$major.$minor.$patch"
}

update_version() {
  local file="$1"
  local new_version="$2"

  sed -i "/display_version / s/\([0-9]\)\.\([0-9]\)\.\([0-9]\)/$new_version/g" "$file"
}

current_version=$(get_version "${1:?'File is mandatory'}")

new_version=$(increment_version "$current_version" "${2:-patch}")

update_version "$1" "$new_version"