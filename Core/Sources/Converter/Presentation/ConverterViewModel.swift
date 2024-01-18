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
  private var updatedAt: Date?

  public init(
    converterRepository: ConverterRepository,
    currencyRepository: CurrencyRepository,
    initialState: ConverterState = ConverterState.initial
  ) {
    self.converterRepository = converterRepository
    self.currencyRepository = currencyRepository
    state = initialState
    Task { await load(forceRefresh: false) }
    syncUpdatedAt()
  }

  // swiftlint:disable function_body_length
  public func send(_ action: ConverterAction) {
    switch action {
      
    case let .addAcurrency(currency):
      state.isSelectCurrencyOpen = false
      Task { await currencyRepository.markCurrencyUsed(currency) }
      let newBaseCurrencyValue = getCurrencyWithRate(for: currency.code)
        .withValue(10)
      state.values.appendOrMoveToLast(newBaseCurrencyValue, comparingValue: \.currency)
      resetValues(
        baseCurrency: currency,
        prevBaseCurrency: state.values.first(where: { $0.currency == currency })?.currency
      )
      Task { await storeSelectedCurrencies() }

    case let .changeCurrency(prev, new):
      state.isSelectCurrencyOpen = false
      let replacedIndex = state.values.firstIndex(where: { $0.currency == prev })!
      Task { await currencyRepository.markCurrencyUsed(new) }
      resetValues(
        baseCurrency: new,
        prevBaseCurrency: prev
      )
      Task { await storeSelectedCurrencies() }
      
    case .closeSelectCurrency:
      state.searchQuery = ""
      state.searchCurrencies = currencies
      state.isSelectCurrencyOpen = false
      
    case let .openSelectCurrency(selectedCurrency):
      state.selectedCurrency = selectedCurrency
      state.isSelectCurrencyOpen = true
      
    case .refresh:
      Task { await load(forceRefresh: true) }
      
    case let .removeCurrency(currency):
      let removedIndex = state.values.firstIndex(where: { $0.currency == currency })!
      state.values.remove(at: removedIndex)
      Task { await storeSelectedCurrencies() }

    case let .searchCurrencies(query):
      self.state.searchQuery = query
      Task {
        let searchResult = await currencyRepository.getCurrencies(
          query: query,
          sorting: state.sorting
        )
        emit {
          self.state.searchCurrencies = searchResult.or(default: [])
        }
      }
      
    case let .setSorting(sorting):
      Task {
        let searchResult = await currencyRepository.getCurrencies(
          query: "",
          sorting: sorting
        )
        emit {
          self.state.searchCurrencies = searchResult.or(default: [])
          self.state.sorting = sorting
        }
      }

    case let .updateValue(currencyValue):
      state.selectedCurrency = currencyValue.currency
      state.values = state.values.map { v in
        v.currency == currencyValue.currency
          ? currencyValue
          : currencyValue.convert(to: v.currencyWithRate)
      }
    }
  }
  // swiftlint:enable function_body_length

  private func load(forceRefresh: Bool) async {
    emit {
      self.state.isLoading = true
    }

    let currenciesResult = await currencyRepository.getCurrencies(sorting: state.sorting)
    guard let currencies = currenciesResult.orNil() else {
      emit {
        self.state.isLoading = false
        self.state.error = currenciesResult.requireFailure()
          .toErrorModel(message: "Cannot load currencies")
      }
      return
    }
    self.currencies = currencies

    let selectedCurrenciesResult = await converterRepository.getSelectedCurrencies()
    guard let selectedCurrencies = selectedCurrenciesResult.orNil() else {
      emit {
        self.state.isLoading = false
        self.state.error = selectedCurrenciesResult.requireFailure()
          .toErrorModel(message: "Cannot load selected currencies")
      }
      return
    }

    let ratesResult = await currencyRepository.getLatestRates(forceRefresh: forceRefresh)
    guard let rates = ratesResult.orNil() else {
      emit {
        self.state.isLoading = false
        self.state.error = ratesResult.requireFailure()
          .toErrorModel(message: "Cannot load rates")
      }
      return
    }
    self.rates = rates.items
    self.updatedAt = rates.updatedAt

    let baseCurrencyValue = getCurrencyWithRate(for: selectedCurrencies.currencyCodes.first!)
      .withValue(10)

    emit {
      self.state.isLoading = false
      self.state.error = nil
      self.state.searchCurrencies = currencies
      self.state.values = selectedCurrencies.currencyCodes.map { currencyCode in
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
  
  private func resetValues(baseCurrency: Currency, prevBaseCurrency: Currency?) {
    let prevBaseCurrency = prevBaseCurrency ?? baseCurrency
    let baseIndex = state.values.firstIndex(where: { $0.currency == prevBaseCurrency })!
    
    let newBaseCurrencyValue = getCurrencyWithRate(for: baseCurrency.code)
      .withValue(10)
    
    state.values = state.values.mapWithIndices { (index, currencyValue) in
      if index == baseIndex {
        newBaseCurrencyValue
        
      } else if currencyValue.currency == baseCurrency {
        newBaseCurrencyValue
          .convert(to: getCurrencyWithRate(for: prevBaseCurrency.code))
        
      } else {
        newBaseCurrencyValue
          .convert(to: getCurrencyWithRate(for: currencyValue.currency.code))
      }
    }
  }
  
  private func storeSelectedCurrencies() async {
    await converterRepository.setSelectedCurrencies(state.values.map(\.currency.code))
  }
  
  private func syncUpdatedAt() {
    let timer = Timer(timeInterval: 1, repeats: true) { _ in
      if let updatedAt = self.updatedAt {
        self.emit { self.state.updatedAt = updatedAt.formatted(.relative(presentation: .named)) }
      }
    }
    RunLoop.current.add(timer, forMode: .common)
  }
}

public extension ConverterViewModel {
  static let samples = ConverterViewModelSamples()
}

public class ConverterViewModelSamples {
  public let success = ConverterViewModel(
    converterRepository: FakeConverterRepository(
      selectedCurrencies: .samples.alphabetical
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
      currenciesResult: .failure(.network(cause: .unknown))
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
