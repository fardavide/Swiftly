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
          allCurrencies: state.allCurrencies,
          values: state.values,
          onCurrencyValueChange: { currencyValue in
            viewModel.send(.valueUpdate(currencyValue: currencyValue))
          },
          onCurrencyChange: { prev, new in
            viewModel.send(.currencyChange(prev: prev, new: new))
          }
        )
      }
    }
  }
}

private struct ContentView: View {
  let allCurrencies: [Currency]
  let values: [CurrencyValue]
  @State private var isShowingSheet = false
  let onCurrencyValueChange: (CurrencyValue) -> ()
  let onCurrencyChange: (_ prev: Currency, _ new: Currency) -> ()
  
  var body: some View {
    List(values, id: \.currency) { value in
      CurrencyValueRow(
        value: value,
        onValueChange: { newValue in
          onCurrencyValueChange(newValue.of(value.currencyWithRate))
        }
      )
      #if os(iOS)
      .swipeActions(edge: .trailing) {
        Button { isShowingSheet = true } label: {
          Label("Change currency", systemImage: "arrow.left.arrow.right")
            .tint(Color.accentColor)
        }
      }
      #endif
      .contextMenu {
        Button("Change currency") {
          isShowingSheet = true
        }
      }
      .sheet(isPresented: $isShowingSheet) {
        SelectCurrencySheet(
          currencies: allCurrencies,
          onCurrencySelected: { newCurrency in
            onCurrencyChange(value.currency, newCurrency)
            isShowingSheet = false
          }
        )
      }
    }
  }
}

private struct CurrencyValueRow: View {
  let value: CurrencyValue
  let onValueChange: (Double) -> ()
  
  var body: some View {
    let currency = value.currency
    let textFieldBinding = Binding(get: { value.value }, set: onValueChange)
    
    HStack {
      HStack {
        Text(currency.flag)
          .font(.largeTitle)
        Text(currency.code)
      }
      .accessibilityElement(children: .ignore)
      .accessibilityLabel("Currency: \(currency.name)")
      Spacer()
      VStack(alignment: .trailing) {
        TextField(
          "Value",
          value: textFieldBinding,
          format: .number.precision(.fractionLength(2))
        )
        .font(.title2)
        .multilineTextAlignment(.trailing)
        Text(currency.nameWithSymbol)
          .font(.caption)
      }
      .accessibilityElement(children: .ignore)
      .accessibilityLabel("\(value.value) \(currency.symbol)")
    }
  }
}

#Preview("Success") {
  Provider.setupPreview(viewModel: ConverterViewModel.samples.success)
  return ConverterView()
}

#Preview("Network error") {
  Provider.setupPreview(viewModel: ConverterViewModel.samples.networkError)
  return ConverterView()
}

#Preview("Storage error") {
  Provider.setupPreview(viewModel: ConverterViewModel.samples.storageError)
  return ConverterView()
}
