#!/usr/bin/env bash

# exit on error
set -e

cd $1

function download() {
    # -L = follow redirects
    curl -qL $1 2>/dev/null
}

function download_things() {
  download https://api.github.com/repos/SuperCuber/dotter/releases/latest | jq --raw-output ".assets | map(.browser_download_url) | .[]" | while read line;
  do
    FILENAME=$(echo ${line} | rev | cut -d / -f 1 | rev)
    echo Downloading \"$FILENAME\"...
    # overwrite dotter installation
    download ${line} > $FILENAME
    echo FINISHED downloading \"$FILENAME\"
    if [[ $FILENAME != *.exe ]]
    then
      echo Adding EXECUTE permissions to ./$FILENAME
      chmod +x ./$FILENAME
    fi
  done

  # Example value: 'Dotter 1.0.0'
  DOTTER_VERSION=$(./dotter --version 2>/dev/null)
  if [[ $DOTTER_VERSION != "" ]]
  then
    echo Successfully downloaded $DOTTER_VERSION
  else
    >&2 echo ERROR: Couldn\'t download the dotter update!
  fi
}

echo "::set-output name=old-version::$(chmod +x ./dotter && ./dotter --version 2>/dev/null)"
# print stderr in red and stdout in green
download_things 2> >(while read line; do echo -e "\e[01;31m$line\e[0m" >&2; done) 1> >(while read line; do echo -e "\e[01;32m$line\e[0m" >&2; done)
echo "::set-output name=new-version::$(./dotter --version 2>/dev/null)"