#!/bin/bash
TMP_FILE=tmp.txt

# url decode
# winpty python -c 'import urllib.parse, sys; print(urllib.parse.unquote(sys.argv[1]))' <url>

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
  cat index.html | grep href | grep -v '\.\.\/' | sed -e 's;<a href=";;' -e 's;</a>.*;;' -e 's;">;\n;' > $TMP_FILE
  while read -r url_
  do
    read -r name_
    if [[ "$url_" =~ .*\/$ ]]
    then
      [[ ! -e "$name_" ]] && mkdir "$name_"
      cd "$name_"
      download_dir "$baseurl_" "$url_" "$name_"
      cd ..
    elif [[ "$url_" =~ .*\.html$ ]]
    then
      [[ ! -e "$name_" ]] && download_file "$baseurl_" "$url_" "$name_"
    fi
  done < $TMP_FILE
}

baseurl=http://lingxi.live/
while read -r url
do
  read -r name
  [[ ! -e "$name" ]] && mkdir "$name"
  cd "$name"
  download_dir "$baseurl" "$url" "$name"
  cd ..
done
