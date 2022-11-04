#!/bin/bash
TMP_FILE=tmp.txt

function download_file() {
  local baseurl=$1
  local url=$2
  local name=$3
  curl -s "${baseurl}${url}" > "$name"
}

function download_dir() {
  local baseurl=$1
  local url=$2
  local name=$3

  local baseurl_="${baseurl}${url}"
  local url_=
  local name_=

  curl -s "$baseurl_" > index.html
  cat index.html | grep href | grep -v '\.\.' | sed -e 's;<a href=";;' -e 's;</a>.*;;' -e 's;">;\n;' > $TMP_FILE
  while read -r url_
  do
    read -r name_
    if [[ "$url_" =~ .*\/$ ]]
    then
      mkdir "$name_" && cd "$name_"
      download_dir "$baseurl_" "$url_" "$name_"
      cd ..
    else
      download_file "$baseurl_" "$url_" "$name_"
    fi
  done < $TMP_FILE
}

baseurl=http://lingxi.live/
while read -r url
do
  read -r name
  mkdir "$name" && cd "$name"
  download_dir "$baseurl" "$url" "$name"
  cd ..
done
