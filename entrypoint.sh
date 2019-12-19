#!/bin/sh

set -u

root_file="$1"
GITHUB_TOKEN="$2"
GITHUB_EVENT_PATH="$3"
REPOSITORY="$4"
TAG="$5"

echo "${root_file}"
echo "this is repository name:"
echo "${REPOSITORY}"
echo "${TAG}"

% extract file name without extension
root_name="${root_file%.*}"

uplatex $root_file
pbibtex $root_name
uplatex  $root_file
uplatex $root_file
uplatex $root_file
dvipdfmx $root_name

ACCEPT_HEADER="Accept: application/vnd.github.jean-grey-preview+json"
TOKEN_HEADER="Authorization: token ${GITHUB_TOKEN}"
ENDPOINT="https://api.github.com/repos/${REPOSITORY}/releases"

echo "Creatting new release as version ${TAG}..."
REPLY=$(curl -H "${ACCEPT_HEADER}" -H "${TOKEN_HEADER}" -d "{\"tag_name\": \"${TAG}\", \"name\": \"PDF_UPLOAD\"}" "${ENDPOINT}")

# Check error
RELEASE_ID=$(echo "${REPLY}" | jq .id)
if [ "${RELEASE_ID}" = "null" ]; then
  echo "Failed to create release. Please check your configuration. Github replies:"
  echo "${REPLY}"
  exit 1
fi

echo "Github release created as ID: ${RELEASE_ID}"
RELEASE_URL="https://uploads.github.com/repos/${REPOSITORY}/releases/${RELEASE_ID}/assets"

# Uploads artifacts
FILE="/github/workspace/${root_name}.pdf"
MIME=$(file -b --mime-type "${FILE}")
echo "Uploading assets ${FILE} as ${MIME}..."
NAME=$(basename "${FILE}")
curl -v \
  -H "${ACCEPT_HEADER}" \
  -H "${TOKEN_HEADER}" \
  -H "Content-Type: ${MIME}" \
  --upload-file "${FILE}" \
  "${RELEASE_URL}?name=${NAME}"

echo "Finished."
