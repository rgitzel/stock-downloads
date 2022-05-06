#!/usr/bin/env bash

set -eux

API_KEY="${1}"

OUTPUT_FILE="${2:-/tmp/downloaded-stocks.txt}"

SYMBOLS=(
  "TSE:COW"
  "TSE:XSP"
)


# --------------------------

rm -f "${OUTPUT_FILE}"
touch "${OUTPUT_FILE}"

for SYMBOL in "${SYMBOLS[@]}"
do
  url="https://www.alphavantage.co/query?function=TIME_SERIES_WEEKLY_ADJUSTED&symbol=${SYMBOL}&apikey=${API_KEY}"

  #
  # the response is going to look like this
  #
  #    {
  #        "Meta Data": {
  #            "1. Information": "Weekly Adjusted Prices and Volumes",
  #            "2. Symbol": "AMZN",
  #            "3. Last Refreshed": "2022-05-04",
  #            "4. Time Zone": "US/Eastern"
  #        },
  #        "Weekly Adjusted Time Series": {
  #            "2022-05-04": {
  #                "1. open": "2448.0200",
  #                "2. high": "2524.4100",
  #                "3. low": "2367.5000",
  #                "4. close": "2518.5700",
  #                "5. adjusted close": "2518.5700",
  #                "6. volume": "16904877",
  #                "7. dividend amount": "0.0000"
  #            },
  #

  curl -s "${url}" \
   | jq -r '.["Weekly Adjusted Time Series"] 
      | to_entries | .[] 
      | (
          "SYMBOL " 
          + ( .value | .["4. close"] | tostring ) 
          + " " 
          + ( (.key + "T00:00:00Z") | fromdateiso8601 | tostring )
        )
     ' \
   | sed -e "s/SYMBOL/${SYMBOL}/g" \
   >> "${OUTPUT_FILE}"

done

