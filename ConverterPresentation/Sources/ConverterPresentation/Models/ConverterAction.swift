//
//  ConverterAction.swift
//  App
//
//  Created by Davide Giuseppe Farella on 25/10/23.
//

import CurrencyDomain

public enum ConverterAction {
  
  /// Called when the use changes a Currency
  case currencyChange(prev: Currency, new: Currency)
  
  /// Called when the user updates some value for a given Currency
  case valueUpdate(currencyValue: CurrencyValue)
}
