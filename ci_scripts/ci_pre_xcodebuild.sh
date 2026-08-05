#!/bin/sh
echo "Adding API keys"

# Navigate to the directory containing ApiKey.swift
#
# This has to be the copy inside the SwiftlyCore package, because that is the one the `CurrencyApi` target
# compiles. Until now it pointed at `Core/Sources/…`, the pre-2996b67 location: the "Chore: move Core ->
# SwiftlyCore" commit could not carry `ApiKey.swift` along — .gitignore excludes it — so the old path kept
# existing, kept being written to, and was compiled by nothing. Every build since shipped the committed
# placeholder, which is three empty strings, and every request went out with an empty key.
#
# Failing loudly if it is not there is the point: writing the keys somewhere nothing reads is exactly the
# failure this is recovering from, and it took months to notice.
cd ../SwiftlyCore/Sources/Currency/Data/Api || {
  echo "error: cannot find the directory holding ApiKey.swift"
  exit 1
}

# Rewrite ApiKey.swift with the new content
cat > ApiKey.swift <<EOF
class ApiKey {
  static let currencyApiCom = "$CurrencyApiComKey"
  static let currencyBeaconCom = "$CurrencyBeaconComKey"
  static let exchangeRatesIo = "$ExchangeRatesIoKey"
}
EOF

# Say so — loudly — when a key is missing from the environment. A build with no key still runs, it just
# cannot refresh anything, and the app now reports that as "this build has no API key" instead of guessing.
for name in CurrencyApiComKey CurrencyBeaconComKey ExchangeRatesIoKey; do
  eval value=\$$name
  if [ -z "$value" ]; then
    echo "warning: $name is not set, the build will ship without that API key"
  fi
done

# Display the updated file for verification (optional)
cat ApiKey.swift

exit 0
