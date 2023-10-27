//
//  AppApp.swift
//  App
//
//  Created by Davide Giuseppe Farella on 22/10/23.
//

import CommonProvider
import ConverterPresentation
import CurrencyApi
import CurrencyData
import SwiftUI

@main
struct AppApp: App {
  private let provider = Provider.instance
  
  init() {
    converterPresentationRegistry(provider: provider)
    currencyApiRegistry(provider: provider)
    currencyDataRegistry(provider: provider)
  }
  
  var body: some Scene {
    WindowGroup {
      ConverterView()
    }
  }
}
