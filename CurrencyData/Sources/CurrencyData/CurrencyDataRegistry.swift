//
//  File.swift
//  
//
//  Created by Davide Giuseppe Farella on 27/10/23.
//

import CommonProvider
import CurrencyDomain

public func currencyDataRegistry(provider: Provider) {
  provider
    .register {
      RealCurrencyRepository(api: provider.get()) as CurrencyRepository
    }
}
