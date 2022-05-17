#!/usr/bin/env bash

set -eu

CURRENCY=${1:-CAD}
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

  echo "price,symbol=$symbol,currency=${CURRENCY}  price=$price $millis"
done


