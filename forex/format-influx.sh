#!/usr/bin/env bash

set -eu

INPUT_FILE="${2:-/tmp/downloaded-exchange-rates.txt}"

LINES=()
while IFS= read -r line; do
  LINES+=("$line")  
done < ${INPUT_FILE}

for line in "${LINES[@]}"; do
  splits=($(echo "${line// /$'\n'}"))
  rate=${splits[0]}
  millis=${splits[1]}

  echo "forex,from=USD,to=CAD rate=$rate $millis"
done


