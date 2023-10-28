//
//  ConverterState.swift
//  App
//
//  Created by Davide Giuseppe Farella on 25/10/23.
//

import CurrencyDomain

public struct ConverterState {
  var error: String?
  var isLoading: Bool
  var values: [CurrencyValue]
}

public extension ConverterState {
  static let initial = ConverterState(
    isLoading: true,
    values: []
  )
  static let sample = ConverterState(
    isLoading: false,
    values: CurrencyValue.samples
  )
}
