import CommonUtils
import ConverterDomain
import CurrencyDomain
import Foundation

public final class ConverterViewModel: ViewModel {
  public typealias Action = ConverterAction
  public typealias State = ConverterState
  
  private let converterRepository: ConverterRepository
  private let currencyRepository: CurrencyRepository
  @Published public var state: State
  
  public init(
    converterRepository: ConverterRepository,
    currencyRepository: CurrencyRepository,
    initialState: ConverterState = ConverterState.initial
  ) {
    self.converterRepository = converterRepository
    self.currencyRepository = currencyRepository
    state = initialState
    Task { await load() }
  }
  
  public func send(_ action: ConverterAction) {
    switch action {
      
    case let .currencyChange(prev, new):
      state.values = state.values.map { v in
        if v.currency == prev {
          CurrencyValue(
            value: 10,
            currencyWithRate: state.values.first(where: { value in value.currency == new })!.currencyWithRate
          )
        } else if v.currency == new {
          CurrencyValue(
            value: 10,
            currencyWithRate: state.values.first(where: { value in value.currency == prev })!.currencyWithRate
          )
        } else {
          v
        }
      }
      
    case let .valueUpdate(currencyValue):
      state.values = state.values.map { v in
        v.currency == currencyValue.currency
        ? currencyValue
        : CurrencyValue(
          value: currencyValue.value * (v.rate / currencyValue.rate),
          currencyWithRate: v.currencyWithRate
        )
      }
      
    }
  }
  
  private func load() async {
    emit {
      self.state.isLoading = true
    }
    
    let currenciesResult = await currencyRepository.getCurrencies()
    guard let currencies = currenciesResult.orNil() else {
      emit {
        self.state.isLoading = false
        self.state.error = "Cannot load currencies: \(currenciesResult)"
      }
      return
    }
    
    let favoriteCurrenciesResult = await converterRepository.getFavoriteCurrencies()
    guard let favoriteCurrencies = favoriteCurrenciesResult.orNil() else {
      emit {
        self.state.isLoading = false
        self.state.error = "Cannot load favorite currencies: \(favoriteCurrenciesResult)"
      }
      return
    }
    
    let ratesResult = await currencyRepository.getLatestRates()
    guard let rates = ratesResult.orNil() else {
      emit {
        self.state.isLoading = false
        self.state.error = "Cannot load rates: \(ratesResult)"
      }
      return
    }
    
    emit {
      self.state.isLoading = false
      self.state.error = nil
      self.state.allCurrencies = currencies
      self.state.values = favoriteCurrencies.currencyCodes.map { currencyCode in
        let currency = currencies.first(where: { $0.code == currencyCode })!
        let rate = rates.first(where: { $0.currencyCode == currencyCode })!
        return CurrencyValue(
          value: 10,
          currencyWithRate: CurrencyWithRate(
            currency: currency,
            rate: rate.rate
          )
        )
      }
    }
  }
}

public extension ConverterViewModel {
  static let samples = ConverterViewModelSamples()
}

public class ConverterViewModelSamples {
  let success = ConverterViewModel(
    converterRepository: FakeConverterRepository(),
    currencyRepository: FakeCurrencyRepository(
      currencies: Currency.samples.all(),
      currencyRates: CurrencyRate.samples.all()
    )
  )
  let networkError = ConverterViewModel(
    converterRepository: FakeConverterRepository(),
    currencyRepository: FakeCurrencyRepository(
      currenciesResult: .failure(.network)
    )
  )
  let storageError = ConverterViewModel(
    converterRepository: FakeConverterRepository(),
    currencyRepository: FakeCurrencyRepository(
      currenciesResult: .failure(.storage)
    )
  )
}
