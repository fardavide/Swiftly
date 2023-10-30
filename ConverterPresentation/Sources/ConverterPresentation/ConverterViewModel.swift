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
    case let .update(currencyValue):
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
    DispatchQueue.main.async {
      self.state.isLoading = true
    }
    
    let currenciesResult = await repository.getCurrencies()
    let ratesResult = await repository.getLatestRates()
    
    let result = await repository.getCurrencies()
      .then { currencies in
        await repository.getLatestRates().map { rates in
          rates.compactMap { currencyRate in
            if let currency = currencies.first(where: { $0.code == currencyRate.currencyCode }) {
              CurrencyValue(
                value: 0,
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
    DispatchQueue.main.async {
      self.state.isLoading = false
      
      switch result {
      case let .success(rates):
        self.state.values = rates
        self.state.error = nil
      case let .failure(error):
        self.state.error = "Something went wrong: \(error)"
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
