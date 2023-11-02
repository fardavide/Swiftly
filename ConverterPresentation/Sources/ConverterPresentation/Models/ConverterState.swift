//
//  ConverterState.swift
//  App
//
//  Created by Davide Giuseppe Farella on 25/10/23.
//

import CurrencyDomain

public struct ConverterState {
  var allCurrencies: [Currency]
  var error: String?
  var isLoading: Bool
  var values: [CurrencyValue]
}

public extension ConverterState {
  static let initial = ConverterState(
    allCurrencies: [],
    isLoading: true,
    values: []
  )
  static let sample = ConverterState(
    allCurrencies: Currency.samples.all(),
    isLoading: false,
    values: CurrencyValue.samples.all()
  )
}
