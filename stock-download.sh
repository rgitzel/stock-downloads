#!/usr/bin/env bash

set -eu

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 API_KEY SYMBOLS_COMMA_DELIMITED [OUTPUT_FILE]"
    exit 1
fi

API_KEY="${1}"
SYMBOLS_COMMA_DELIMITED="${2}"
OUTPUT_FILE="${3:-/tmp/downloaded-stocks.txt}"

SYMBOLS=($(echo "${SYMBOLS_COMMA_DELIMITED//,/$'\n'}"))

# --------------------------

rm -f "${OUTPUT_FILE}"
touch "${OUTPUT_FILE}"

for symbol in "${SYMBOLS[@]}"
do
  echo "downloading ${symbol}"

  # build the entire command here, as interpolating with quotes is tricky, and it seems single-quotes are
  #  added around the URL utomatically by `$(...)`?
  command="curl -s https://www.alphavantage.co/query?function=TIME_SERIES_WEEKLY_ADJUSTED&symbol=${symbol}&apikey=${API_KEY}"

  response="$(${command})"

  error=$(echo "${response}" | jq -r '.["Error Message"]')

  if [[ "$error" != "null" ]]; then
    echo "skipping '$symbol': ${error}"
  else
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
    #            ...
    #
    echo "${response}" \
     | jq -r '.["Weekly Adjusted Time Series"] 
        | to_entries | .[] 
        | (
            "SYMBOL_THAT_IS_DIFFICULT_TO_INTERPOLATE_HERE " 
            + ( .value | .["4. close"] | tostring ) 
            + " " 
            + ( (.key + "T00:00:00Z") | fromdateiso8601 | tostring )
          )
       ' \
     | sed -e "s/SYMBOL_THAT_IS_DIFFICULT_TO_INTERPOLATE_HERE/${symbol}/g" \
     >> "${OUTPUT_FILE}"
  fi
done

echo "done"

