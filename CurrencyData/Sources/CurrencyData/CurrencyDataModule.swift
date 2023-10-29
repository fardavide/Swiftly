//
//  File.swift
//  
//
//  Created by Davide Giuseppe Farella on 27/10/23.
//

import CommonProvider
import CurrencyApi
import CurrencyDomain
import CurrencyStorage

public final class CurrencyDataModule: Module {
  public init() {}
  
  public var dependencies: [Module.Type] = [
    CurrencyApiModule.self,
    CurrencyStorageModule.self
  ]
  
  public func register(on provider: Provider) {
    provider
      .register {
        RealCurrencyRepository(
          api: provider.get(),
          getCurrentDate: provider.get(),
          storage: provider.get()
        ) as CurrencyRepository
      }
  }
}
