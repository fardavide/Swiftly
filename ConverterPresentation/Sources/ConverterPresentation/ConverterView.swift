//
//  ContentView.swift
//  App
//
//  Created by Davide Giuseppe Farella on 22/10/23.
//

import CommonProvider
import CurrencyDomain
import SwiftUI

public struct ConverterView: View {
  @StateObject var viewModel: ConverterViewModel = getProvider().get()
  
  public init() {}
  
  public var body: some View {
    let state = viewModel.state
    switch state.isLoading {
      
    case true:
      ProgressView()
      
    case false:
      switch state.error {
        
      case let .some(error):
        Text(error)
        
      case .none:
        ContentView(
          values: state.values,
          onCurrencyValueChange: { currencyValue in
            viewModel.send(.update(currencyValue: currencyValue))
          }
        )
      }
    }
  }
}

private struct ContentView: View {
  let values: [CurrencyValue]
  @State private var isShowingSheet = false
  let onCurrencyValueChange: (CurrencyValue) -> ()
  
  var body: some View {
    List(values, id: \.currencyRate) { value in
      CurrencyRow(
        value: value,
        onValueChange: { newValue in
          onCurrencyValueChange(newValue.of(value.currencyRate))
        }
      )
      .swipeActions(edge: .trailing) {
        Button { isShowingSheet = true } label: {
          Label("Change currency", systemImage: "arrow.left.arrow.right")
            .tint(Color.accentColor)
        }
      }
      .contextMenu {
        Button("Change currency") {
          isShowingSheet = true
        }
      }
      .sheet(isPresented: $isShowingSheet) {
        Text("Currencies here")
      }
    }
  }
}

struct CurrencyRow: View {
  let value: CurrencyValue
  let onValueChange: (Double) -> ()
  
  var body: some View {
    let currency = value.currencyRate.currency
    let textFieldBinding = Binding(get: { value.value }, set: onValueChange)
    
    HStack {
      HStack {
        Text(currency.flag)
          .font(.largeTitle)
        Text(currency.code)
      }
      .accessibilityElement(children: .ignore)
      .accessibilityLabel("Currency: \(currency.longName)")
      Spacer()
      VStack(alignment: .trailing) {
        TextField(
          "Value",
          value: textFieldBinding,
          format: .number.precision(.fractionLength(2))
        )
        .font(.title2)
        .multilineTextAlignment(.trailing)
        Text(currency.longNameWithSymbol)
          .font(.caption)
      }
      .accessibilityElement(children: .ignore)
      .accessibilityLabel("\(value.value) \(currency.symbol)")
    }
  }
}

#Preview {
  ConverterView(
//    viewModel: ConverterViewModel(
//      repository: FakeCurrencyRepository()
//    )
  )
}
