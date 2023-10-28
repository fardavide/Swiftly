//
//  File.swift
//  
//
//  Created by Davide Giuseppe Farella on 28/10/23.
//

import CommonProvider

public func currencyApiRegistry(provider: Provider) {
  provider
    .register { RealCurrencyApi() as CurrencyApi }
}
