#!/usr/bin/env bash

set -eu

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 API_KEY [OUTPUT_FILE]"
    exit 1
fi

API_KEY="${1}"
OUTPUT_FILE="${2:-/tmp/downloaded-exchange-rates.txt}"

# --------------------------

rm -f "${OUTPUT_FILE}"
touch "${OUTPUT_FILE}"

echo "downloading USD->CAD"

# build the entire command here, as interpolating with quotes is tricky, and it seems single-quotes are
#  added around the URL utomatically by `$(...)`?
command="curl -s https://www.alphavantage.co/query?function=FX_WEEKLY&from_symbol=USD&to_symbol=CAD&apikey=${API_KEY}"

response="$(${command})"

error=$(echo "${response}" | jq -r '.["Error Message"]')

if [[ "$error" != "null" ]]; then
  echo "skipping '$symbol': ${error}"
else
  #
  # the response is going to look like this
  #
  # {
  #     "Meta Data": {
  #         "1. Information": "Forex Weekly Prices (open, high, low, close)",
  #         "2. From Symbol": "USD",
  #         "3. To Symbol": "CAD",
  #         "4. Last Refreshed": "2022-05-17 18:15:00",
  #         "5. Time Zone": "UTC"
  #     },
  #     "Time Series FX (Weekly)": {
  #         "2022-05-17": {
  #             "1. open": "1.29169",
  #             "2. high": "1.29814",
  #             "3. low": "1.28030",
  #             "4. close": "1.28285"
  #         },
  #         "2022-05-13": {
  #             "1. open": "1.29030",
  #             "2. high": "1.30766",
  #             "3. low": "1.28867",
  #             "4. close": "1.29080"
  #         },
  #            ...
  # note we'll skip the first one
  #
  echo "${response}" \
   | jq -r '.["Time Series FX (Weekly)"]
      | to_entries[1:] | .[]
      | (
          ( .value | .["4. close"] | tostring )
            + " "
            + ( (.key + "T00:00:00Z") | fromdateiso8601 | tostring )
        )
     ' \
   >> "${OUTPUT_FILE}"
fi

echo "done"

