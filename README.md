# stock-downloads

A handful of scripts for pulling down stock prices I'm interested in,
 and then formatting them appropriately for import into Quicken and into
 InfluxDB.

This makes use of the free API from [Alpha Vantage](https://www.alphavantage.co).
 It's pretty cool they've made this available, and they seem keen to
 support small projects like this. :-)

The scripts are so far meant for OSX. Eventually I'll move them to my
 Synology NAS to be run as a `cron` job, and will convert any commands
 to proper Linux.

You'll need `jq` to run the downloading script.


