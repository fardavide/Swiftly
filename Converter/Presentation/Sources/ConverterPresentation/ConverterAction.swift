//
//  ConverterAction.swift
//  App
//
//  Created by Davide Giuseppe Farella on 25/10/23.
//

import CurrencyDomain

public enum ConverterAction {
  
  /*
   Called when the user updates some value for a given Currency
   */
  case update(currencyValue: CurrencyValue)
}
