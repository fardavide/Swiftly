import CommonUtils

public protocol ConverterRepository {
  
  func getFavoriteCurrencies() async -> Result<FavoriteCurrencies, DataError>
}

public final class FakeConverterRepository: ConverterRepository {
  
  private let favoriteCurrenciesResult: Result<FavoriteCurrencies, DataError>
  
  public init(
    favoriteCurrenciesResult: Result<FavoriteCurrencies, DataError> = .failure(.unknown)
  ) {
    self.favoriteCurrenciesResult = favoriteCurrenciesResult
  }
  
  public convenience init(
    favoriteCurrencies: FavoriteCurrencies
  ) {
    self.init(
      favoriteCurrenciesResult: .success(favoriteCurrencies)
    )
  }
  
  public func getFavoriteCurrencies() async -> Result<FavoriteCurrencies, DataError> {
    favoriteCurrenciesResult
  }
}
