import ConverterDomain
import CurrencyDomain
import Foundation
import SwiftlyUtils

public final class ConverterViewModel: ViewModel {
  public typealias Action = ConverterAction
  public typealias State = ConverterState

  private let converterRepository: ConverterRepository
  private let currencyRepository: CurrencyRepository
  @Published public var state: State

  private var currencies: [Currency] = []
  private var rates: [CurrencyRate] = []

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

    case let .changeCurrency(prev, new):
      let replacedIndex = state.values.firstIndex(where: { $0.currency == prev })!
      Task { await converterRepository.setCurrencyAt(position: replacedIndex, currency: new) }
      let newBaseCurrencyValue = getCurrencyWithRate(for: new.code)
        .withValue(10)

      state.values = state.values.map { currencyValue in
        if currencyValue.currency == prev {
          newBaseCurrencyValue

        } else if currencyValue.currency == new {
          newBaseCurrencyValue
            .convert(to: getCurrencyWithRate(for: prev.code))

        } else {
          newBaseCurrencyValue
            .convert(to: getCurrencyWithRate(for: currencyValue.currency.code))
        }
      }

    case let .searchCurrencies(query):
      self.state.searchQuery = query
      Task {
        let searchResult = await currencyRepository.searchCurrencies(
          query: query,
          sorting: state.sorting
        )
        emit {
          self.state.searchCurrencies = searchResult.or(default: [])
        }
      }
      
    case let .setSorting(sorting):
      Task {
        let searchResult = await currencyRepository.searchCurrencies(
          query: "",
          sorting: sorting
        )
        emit {
          self.state.searchCurrencies = searchResult.or(default: [])
          self.state.sorting = sorting
        }
      }

    case let .updateValue(currencyValue):
      state.values = state.values.map { v in
        v.currency == currencyValue.currency
          ? currencyValue
          : currencyValue.convert(to: v.currencyWithRate)
      }
    }
  }

  private func load() async {
    emit {
      self.state.isLoading = true
    }

    let currenciesResult = await currencyRepository.getCurrencies(sorting: state.sorting)
    guard let currencies = currenciesResult.orNil() else {
      emit {
        self.state.isLoading = false
        self.state.error = "Cannot load currencies: \(currenciesResult)"
      }
      return
    }
    self.currencies = currencies

    let favoriteCurrenciesResult = await converterRepository.getSelectedCurrencies()
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
    self.rates = rates.items
    emit {
      self.state.updatedAt = rates.updatedAt.formatted(date: .abbreviated, time: .shortened)
    }

    let baseCurrencyValue = getCurrencyWithRate(for: favoriteCurrencies.currencyCodes.first!)
      .withValue(10)

    emit {
      self.state.isLoading = false
      self.state.error = nil
      self.state.searchCurrencies = currencies
      self.state.values = favoriteCurrencies.currencyCodes.map { currencyCode in
        currencyCode == baseCurrencyValue.currency.code
          ? baseCurrencyValue
          : baseCurrencyValue.convert(to: self.getCurrencyWithRate(for: currencyCode))
      }
    }
  }

  private func getCurrencyWithRate(for code: CurrencyCode) -> CurrencyWithRate {
    let currency = currencies.first(where: { $0.code == code })!
    let rate = rates.first(where: { $0.currencyCode == code })!
    return CurrencyWithRate(
      currency: currency,
      rate: rate.rate
    )
  }
}

public extension ConverterViewModel {
  static let samples = ConverterViewModelSamples()
}

public class ConverterViewModelSamples {
  let success = ConverterViewModel(
    converterRepository: FakeConverterRepository(
      selectedCurrencies: .initial
    ),
    currencyRepository: FakeCurrencyRepository(
      currencies: Currency.samples.all(),
      currencyRates: .samples.all
    )
  )
  let networkError = ConverterViewModel(
    converterRepository: FakeConverterRepository(
      selectedCurrencies: .initial
    ),
    currencyRepository: FakeCurrencyRepository(
      currenciesResult: .failure(.network)
    )
  )
  let storageError = ConverterViewModel(
    converterRepository: FakeConverterRepository(
      selectedCurrencies: .initial
    ),
    currencyRepository: FakeCurrencyRepository(
      currenciesResult: .failure(.storage(cause: .unknown))
    )
  )
}
