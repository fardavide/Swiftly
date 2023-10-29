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

private let provider = Provider.start()

@main
struct SwiftlyApp: App {
  
  init() {
    SwiftlyModule().start(with: provider)
  }
  
  var body: some Scene {
    WindowGroup {
      ConverterView()
    }
  }
}
