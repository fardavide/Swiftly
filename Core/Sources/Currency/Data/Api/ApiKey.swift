import Foundation

// swiftlint:disable force_cast
class ApiKey {
  static let currencyApiCom = Bundle.main.infoDictionary!["CurrencyApiComKey"] as! String
  static let currencyBeaconCom = Bundle.main.infoDictionary!["CurrencyBeaconComKey"] as! String
  static let exchangeRatesIo = Bundle.main.infoDictionary!["ExchangeRatesIoKey"] as! String
}
// swiftlint:enable force_cast
