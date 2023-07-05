#!/usr/bin/env bash

get_version() {
  local file="$1"
  grep "display_version " "$file" | grep -oP '\d+\.\d+\.\d+'
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
      major=$(echo "$major + 1" | bc)
      minor=0
      patch=0
      ;;

    minor)
      minor=$(echo "$minor + 1" | bc)
      patch=0
      ;;

    patch)
      patch=$(echo "$patch + 1" | bc)
      ;;
  esac

  echo "$major.$minor.$patch"

}

update_version() {
  local new_version="$1"
  local file="$2"

  sed -Ei "/display_version / s/[0-9]+\.[0-9]+\.[0-9]+/$new_version/g" "$file"
}

case ${1:-patch} in
  patch)
    semver="patch"
    ;;
  minor)
    semver="minor"
    ;;
  major)
    semver="major"
    ;;
esac

shift 1

for file in $(ls scripts/*.sh); do
  current_version=$(get_version "$file")
  new_version=$(increment_version "$current_version" "$semver")
  update_version "$new_version" "$file"
done
