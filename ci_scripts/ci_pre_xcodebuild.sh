#!/bin/sh
echo "Adding API keys"

# Navigate to the directory containing ApiKey.swift
cd ../Core/Sources/Currency/Data/Api

# Rewrite ApiKey.swift with the new content
cat > ApiKey.swift <<EOF
class ApiKey {
  static let currencyApiCom = "$CurrencyApiComKey"
  static let currencyBeaconCom = "$CurrencyBeaconComKey"
  static let exchangeRatesIo = "$ExchangeRatesIoKey"
}
EOF

# Display the updated file for verification (optional)
cat ApiKey.swift

exit 0
