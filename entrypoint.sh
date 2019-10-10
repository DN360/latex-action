#!/bin/sh

set -e

root_file="$1"
working_directory="$2"
compiler="$3"
args="$4"
extra_packages="$5"
extra_system_packages="$6"

if [ -n "$extra_system_packages" ]; then
  for pkg in $extra_system_packages; do
    echo "Install $pkg by apk"
    apk --no-cache add "$pkg"
  done
fi

if [ -n "$extra_packages" ]; then
  tlmgr update --self
  for pkg in $extra_packages; do
    echo "Install $pkg by tlmgr"
    tlmgr install "$pkg"
  done
fi

if [ -n "$working_directory" ]; then
  cd "$working_directory"
fi

#texliveonfly -c "$compiler" -a "$args" "$root_file"
latexmk -c "$root_file"

# create release
res=`curl -H "Authorization: token $GITHUB_TOKEN" -X POST https://api.github.com/repos/KONEPITO1205/Graduate_Report/releases \
-d "
{
  \"tag_name\": \"v$GITHUB_SHA\",
  \"target_commitish\": \"$GITHUB_SHA\",
  \"name\": \"v$GITHUB_SHA\",
  \"draft\": false,
  \"prerelease\": false
}"`

echo ${res}

# extract release id
rel_id=`echo ${res} | python3 -c 'import json,sys;print(json.load(sys.stdin)["id"])'`

# upload built pdf
curl -H "Authorization: token $GITHUB_TOKEN" -X POST https://uploads.github.com/repos/KONEPITO1205/Graduate_Report/releases/${rel_id}/assets?name=main.pdf\
  --header 'Content-Type: application/pdf'\
  --upload-file main.pdf