//
//  SwiftlyModule.swift
//  App
//
//  Created by Davide Giuseppe Farella on 28/10/23.
//

import CommonDate
import CommonProvider
import ConverterPresentation
import CurrencyData

final class SwiftlyModule : Module {  
  init() {}

  var dependencies: [Module.Type] = [
    CommonDateModule.self,
    ConverterPresentionModule.self,
    CurrencyDataModule.self,
  ]
}
