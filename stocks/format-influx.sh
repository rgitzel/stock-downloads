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

  echo "stock,symbol=$symbol price=$price $millis"
done


