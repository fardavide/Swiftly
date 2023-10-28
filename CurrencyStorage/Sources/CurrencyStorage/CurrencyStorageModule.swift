//
//  File.swift
//  
//
//  Created by Davide Giuseppe Farella on 28/10/23.
//

import CommonProvider

public final class CurrencyStorageModule: Module {
  public init() {}
  
  public func register(on provider: Provider) {
    provider
      .register { RealCurrencyStorage() as CurrencyStorage }
  }
}
