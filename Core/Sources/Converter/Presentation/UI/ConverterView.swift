import CurrencyDomain
import NukeUI
import Provider
import SwiftUI
import SwiftlyUtils

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
          searchCurrencies: state.searchCurrencies,
          values: state.values,
          onCurrencyValueChange: { currencyValue in
            viewModel.send(.valueUpdate(currencyValue: currencyValue))
          },
          onCurrencyChange: { prev, new in
            viewModel.send(.currencyChange(prev: prev, new: new))
          },
          onSearchCurrencies: { query in
            viewModel.send(.searchCurrencies(query: query))
          }
        )
      }
    }
  }
}

private struct ContentView: View {
  let searchCurrencies: [Currency]
  let values: [CurrencyValue]
  let onCurrencyValueChange: (CurrencyValue) -> ()
  let onCurrencyChange: (_ prev: Currency, _ new: Currency) -> ()
  let onSearchCurrencies: (_ query: String) -> ()
  
  @State private var isShowingSheet = false
  @State private var selectedCurrencyValue: CurrencyValue? = nil
  
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
        Button {
          selectedCurrencyValue = value
          isShowingSheet = true
        } label: {
          Label("Change currency", systemImage: "arrow.left.arrow.right")
            .tint(Color.accentColor)
        }
      }
#endif
      .contextMenu {
        Button("Change currency") {
          selectedCurrencyValue = value
          isShowingSheet = true
        }
      }
    }
    .sheet(isPresented: $isShowingSheet) {
      SelectCurrencySheet(
        currencies: searchCurrencies,
        onCurrencySelected: { newCurrency in
          onCurrencyChange(selectedCurrencyValue!.currency, newCurrency)
          isShowingSheet = false
        },
        onSearchCurrencies: onSearchCurrencies
      )
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
        LazyImage(
          request: ImageRequest(
            url: currency.flagUrl,
            processors: [
              .resize(height: 25),
              .roundedCorners(radius: 100)
            ]
          )
        )
        .frame(width: 40, height: 25)
        .clipShape(.circle)
        Text(currency.code.value)
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
