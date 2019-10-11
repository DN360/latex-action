#!/bin/sh

set -e

root_file="$1"
GITHUB_TOKEN="$2"
GITHUB_EVENT_PATH="$3"
TAG="$4"

# rm -r /opt/texlive/texdir/texmf-var/fonts/map/dvips && ln -s /opt/texlive/texdir/texmf-var/fonts/map/dvipsj /opt/texlive/texdir/texmf-var/fonts/map/dvips

echo check

kpsewhich -format=tfm rml.tfm

kpsewhich -format=tmf jisg.tmf

latexmk -pdfdvi -latex=platex -synctex=1 -e main.tex

ls

pwd

du -k main.pdf

### Determine  project repository
REPOSITORY="KONPEITO1205/Graduate_Report"

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
FILE="/github/workspace/main.pdf"
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