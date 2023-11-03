//
//  File.swift
//  
//
//  Created by Davide Giuseppe Farella on 27/10/23.
//

import CommonProvider

final public class ConverterPresentionModule: Module {
  public init() {}
  
  public func register(on provider: Provider) {
    provider
      .register {
        ConverterViewModel(
          converterRepository: provider.get(),
          currencyRepository: provider.get()
        )
      }
  }
}
