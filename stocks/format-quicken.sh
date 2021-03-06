#!/usr/bin/env bash

set -eu

INPUT_FILE="${2:-/tmp/downloaded-stocks.txt}"

LINES=()
while IFS= read -r line; do
  LINES+=("$line")  
done < ${INPUT_FILE}

for line in "${LINES[@]}"; do
  splits=($(echo "${line// /$'\n'}"))
  symbol=${splits[0]}
  price=${splits[1]}
  millis=${splits[2]}

  # use this on a Mac
  #date=$(date -ur $millis +"%m/%d/%Y")
  # use this for Linux
  date=$(date -d @$millis +"%m/%d/%Y")


  echo "$symbol, $price, $date"
done


