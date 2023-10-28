//
//  ConverterViewModel.swift
//  App
//
//  Created by Davide Giuseppe Farella on 25/10/23.
//

import CommonUtils
import CurrencyDomain
import Foundation

public class ConverterViewModel: ViewModel {
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
        // TODO: extract
        v.currencyWeight.currency == currencyValue.currencyWeight.currency
        ? currencyValue
        : CurrencyValue(
          value: currencyValue.value * (v.currencyWeight.weigth / currencyValue.currencyWeight.weigth),
          currencyWeight: v.currencyWeight
        )
      }
    }
  }
  
  private func load() async {
    DispatchQueue.main.async {
      self.state.isLoading = true
    }
    
    let result = await repository.getLatestRates()
    DispatchQueue.main.async {
      self.state.isLoading = false
      
      switch result {
      case let .success(rates):
        self.state.values = rates
          .filter { rate in Currency.from(code: rate.currency.code) != nil }
          .map { currencyRate in
            CurrencyValue(
              value: 0,
              currencyWeight: CurrencyWeight(
                currency: Currency.from(code: currencyRate.currency.code)!,
                weigth: currencyRate.weigth
              )
            )
          }
        self.state.error = nil
      case let .failure(error):
        self.state.error = "Something went wrong: \(error)"
      }
    }
  }
}