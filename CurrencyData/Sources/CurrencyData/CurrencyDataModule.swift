//
//  File.swift
//  
//
//  Created by Davide Giuseppe Farella on 27/10/23.
//

import CommonProvider
import CurrencyDomain

public final class CurrencyDataModule: Module {
  public init() {}
  
  public func register(on provider: Provider) {
    provider
      .register {
        RealCurrencyRepository(api: provider.get()) as CurrencyRepository
      }
  }
}
