#!/bin/sh
#
# Injects the API keys into the source file the package actually compiles.
#
# The path used to be Core/Sources/... and stayed that way after the module directory was renamed to
# SwiftlyCore. `cd` into a directory that no longer existed failed, `exit 0` swallowed it, and every
# build since shipped the checked-in ApiKey.swift — three empty strings. The requests then went out as
# `?apikey=`, the services answered 401, and the app fell back to cached rates forever. Hence the
# existence check below: a rename must break the build, not the app.
set -eu

script_dir=$(cd "$(dirname "$0")" && pwd)
api_key_file="$script_dir/../SwiftlyCore/Sources/Currency/Data/Api/ApiKey.swift"

if [ ! -f "$api_key_file" ]; then
  echo "error: ApiKey.swift not found at $api_key_file — has the module been moved?" >&2
  exit 1
fi

echo "Adding API keys to $api_key_file"

cat > "$api_key_file" <<EOF
class ApiKey {
  static let currencyApiCom = "${CurrencyApiComKey:-}"
  static let currencyBeaconCom = "${CurrencyBeaconComKey:-}"
  static let exchangeRatesIo = "${ExchangeRatesIoKey:-}"
}
EOF

# The keys themselves are secrets; only report whether each one arrived.
for name in CurrencyApiComKey CurrencyBeaconComKey ExchangeRatesIoKey; do
  eval "value=\${$name:-}"
  if [ -n "$value" ]; then
    echo "  $name: set"
  else
    echo "  warning: $name is empty — the build will ship without that key"
  fi
done
