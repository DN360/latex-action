#!/bin/sh

set -e

root_file="$1"
GITHUB_TOKEN="$2"
#working_directory="$2"
#compiler="$3"
#args="$4"
#extra_packages="$5"
#extra_system_packages="$6"

#if [ -n "$extra_system_packages" ]; then
#  for pkg in $extra_system_packages; do
#    echo "Install $pkg by apk"
#    apk --no-cache add "$pkg"
#  done
#fi

#if [ -n "$extra_packages" ]; then
#  tlmgr update --self
#  for pkg in $extra_packages; do
#    echo "Install $pkg by tlmgr"
#    tlmgr install "$pkg"
#  done
#fi

#if [ -n "$working_directory" ]; then
#  cd "$working_directory"
#fi

#texliveonfly -c "$compiler" -a "$args" "$root_file"

latexmk -pdfdvi -latex=platex -synctex=1 -e main.tex

ls

# latexmk main.tex && latexmk -c main.tex

# ls

pwd

find main.pdf

# Only upload to non-draft releases
#IS_DRAFT=$(jq --raw-output '.release.draft' $GITHUB_EVENT_PATH)
#if [ "$IS_DRAFT" = true ]; then
#  echo "This is a draft, so nothing to do!"
#  exit 0
#fi

# Prepare the headers
#AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"
#CONTENT_LENGTH_HEADER="Content-Length: $(stat -c%s main.pdf)"
#CONTENT_TYPE_HEADER="Content-Type: application/pdf"

# Build the Upload URL from the various pieces
#RELEASE_ID=$(jq --raw-output '.release.id' $GITHUB_EVENT_PATH)
#FILENAME=$(basename main.pdf)
#UPLOAD_URL="https://uploads.github.com/repos/${GITHUB_REPOSITORY}/releases/${RELEASE_ID}/assets?name=${FILENAME}"
#echo "$UPLOAD_URL"

# Upload the file
#curl \
#  -sSL \
#  -XPOST \
#  -H "${AUTH_HEADER}" \
#  -H "${CONTENT_LENGTH_HEADER}" \
#  -H "${CONTENT_TYPE_HEADER}" \
#  --upload-file "main.pdf" \
#  "${UPLOAD_URL}"

# create release
res=`curl -H "Authorization: token $GITHUB_TOKEN" -X POST https://api.github.com/repos/[user]/[repo]/releases \
-d "
{
  \"tag_name\": \"v$GITHUB_SHA\",
  \"target_commitish\": \"$GITHUB_SHA\",
  \"name\": \"v$GITHUB_SHA\",
  \"draft\": false,
  \"prerelease\": false
}"`

# extract release id
rel_id=`echo ${res} | python3 -c 'import json,sys;print(json.load(sys.stdin)["id"])'`

# upload built pdf
curl -H "Authorization: token $GITHUB_TOKEN" -X POST https://uploads.github.com/repos/[user]/[repo]/releases/${rel_id}/assets?name=main.pdf\
  --header 'Content-Type: application/pdf'\
  --upload-file main.pdf