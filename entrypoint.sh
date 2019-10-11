#!/bin/sh

set -e

root_file="$1"
GITHUB_TOKEN="$2"
GITHUB_EVENT_PATH="$3"
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

pwd

find main.pdf

### Determine  project repository
REPOSITORY="KONPEITO1205/Graduate_Report"

### If you are using via some CI service, you can use following server specific variable.

### In Circle CI:
#REPOSITORY="${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}"

### In Travis CI:
#REPOSITORY="${TRAVIS_REPO_SLUG}"

### Determine release tag name
TAG="v0.1.1"

### If you are using via some CI service, you can use following server specific variable.

### In Circle CI:
#TAG="${CIRCLE_TAG}"

### In Travis CI:
#TAG="${TRAVIS_TAG}"


####### You don't need to modify following area #######

ACCEPT_HEADER="Accept: application/vnd.github.jean-grey-preview+json"
TOKEN_HEADER="Authorization: token ${GITHUB_TOKEN}"
ENDPOINT="https://api.github.com/repos/${REPOSITORY}/releases"

echo "Creatting new release as version ${TAG}..."
REPLY=$(curl -H "${ACCEPT_HEADER}" -H "${TOKEN_HEADER}" -d "{\"tag_name\": \"${TAG}\", \"name\": \"${TAG}\"}" "${ENDPOINT}")

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
FILE="main.pdf"
MIME=$(file -b --mime-type "${FILE}")
echo "Uploading assets ${FILE} as ${MIME}..."
NAME=$(basename "${FILE}")
curl -v \
  -H "${ACCEPT_HEADER}" \
  -H "${TOKEN_HEADER}" \
  -H "Content-Type: ${MIME}" \
  --data-binary "@${FILE}" \
  "${RELEASE_URL}?name=${NAME}"
done

echo "Finished."