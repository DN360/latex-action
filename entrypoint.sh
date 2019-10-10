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
latexmk -c "$root_file"

ls

# Only upload to non-draft releases
#IS_DRAFT=$(jq --raw-output '.release.draft' $GITHUB_EVENT_PATH)
#if [ "$IS_DRAFT" = true ]; then
#  echo "This is a draft, so nothing to do!"
#  exit 0
#fi

# Prepare the headers
AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"
CONTENT_LENGTH_HEADER="Content-Length: $(stat -c%s main.pdf)"
CONTENT_TYPE_HEADER="Content-Type: application/pdf"

# Build the Upload URL from the various pieces
RELEASE_ID=$(jq --raw-output '.release.id' $GITHUB_EVENT_PATH)
FILENAME=$(basename main.pdf)
UPLOAD_URL="https://uploads.github.com/repos/${GITHUB_REPOSITORY}/releases/${RELEASE_ID}/assets?name=${FILENAME}"
echo "$UPLOAD_URL"

# Upload the file
curl \
  -sSL \
  -XPOST \
  -H "${AUTH_HEADER}" \
  -H "${CONTENT_LENGTH_HEADER}" \
  -H "${CONTENT_TYPE_HEADER}" \
  --upload-file "main.pdf" \
  "${UPLOAD_URL}"