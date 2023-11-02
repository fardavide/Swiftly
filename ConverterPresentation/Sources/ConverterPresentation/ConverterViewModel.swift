//
//  ConverterViewModel.swift
//  App
//
//  Created by Davide Giuseppe Farella on 25/10/23.
//

import CommonUtils
import CurrencyDomain
import Foundation

public final class ConverterViewModel: ViewModel {
  public typealias Action = ConverterAction
  public typealias State = ConverterState
  
  private let repository: CurrencyRepository
  @Published public var state: State
  
  public init(
    repository: CurrencyRepository,
    initialState: ConverterState = ConverterState.initial
  ) {
    self.repository = repository
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
        v.currency != currencyValue.currency
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
    
    let currenciesResult = await repository.getCurrencies()
    guard let currencies = currenciesResult.orNil() else {
      emit {
        self.state.isLoading = false
        self.state.error = "Cannot load currencies: \(currenciesResult)"
      }
      return
    }
    
    let ratesResult = await repository.getLatestRates()
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
      self.state.values = rates.compactMap { currencyRate in
        if let currency = currencies.first(where: { $0.code == currencyRate.currencyCode }) {
          CurrencyValue(
            value: 10,
            currencyWithRate: CurrencyWithRate(
              currency: currency,
              rate: currencyRate.rate
            )
          )
        } else {
          nil
        }
      }
    }
  }
}

public extension ConverterViewModel {
  static let samples = ConverterViewModelSamples()
}

public class ConverterViewModelSamples {
  let success = ConverterViewModel(
    repository: FakeCurrencyRepository(
      currencies: Currency.samples.all(),
      currencyRates: CurrencyRate.samples.all()
    )
  )
  let networkError = ConverterViewModel(
    repository: FakeCurrencyRepository(
      currenciesResult: .failure(.network)
    )
  )
  let storageError = ConverterViewModel(
    repository: FakeCurrencyRepository(
      currenciesResult: .failure(.storage)
    )
  )
}
