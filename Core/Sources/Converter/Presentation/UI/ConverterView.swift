import AboutPresentation
import CurrencyDomain
import Design
import NukeUI
import Provider
import SwiftUI
import SwiftlyUtils

public struct ConverterView: View {
  @StateObject var viewModel: ConverterViewModel = getProvider().get()
  
  public init() {}
  
  public var body: some View {
    let state = viewModel.state
    
    if state.isLoading && state.values.isEmpty {
      ProgressView()
      
    } else {
      switch state.error {
        
      case let .some(error):
        ErrorView(error) { viewModel.send(.refresh) }
        
      case .none:
        ContentView(
          state: state,
          send: viewModel.send
        )
        .refreshable {
          viewModel.send(.refresh)
        }
        .toolbar {
          // Keyboard close button
          ToolbarItem(placement: .keyboard) {
            Button {
              UIApplication.shared.closeKeyboard()
            } label: {
              Image(systemSymbol: .keyboardChevronCompactDown)
            }
          }
          // Keyboard change currency button
          if !state.values.isEmpty, let currency = state.selectedCurrency {
            ToolbarItem(placement: .keyboard) {
              Button("Change currency") {
                viewModel.send(.openSelectCurrency(selectedCurrency: currency))
              }
            }
          }
          // Updated at text
          if let updatedAt = state.updatedAt {
            ToolbarItem(placement: .status) {
              Text("Updated at: \(updatedAt)")
                .font(.caption2)
            }
          }
        }
        .sheet(isPresented: $viewModel.state.isSelectCurrencyOpen) {
          SelectCurrencySheet(
            uiModel: SelectCurrenciesUiModel(
              currencies: state.searchCurrencies,
              searchQuery: state.searchQuery,
              selectedCurrency: state.requireSelectedCurrency(),
              sorting: state.sorting
            ),
            send: viewModel.send
          )
#if os(macOS)
          .frame(idealWidth: 400, idealHeight: 500)
#endif
        }
      }
    }
  }
}

private struct ContentView: View {
  let state: ConverterState
  let send: (ConverterAction) -> Void
  
  var body: some View {
    List(state.values, id: \.currency) { value in
      CurrencyValueRow(
        currencyValue: value,
        onValueChange: { newValue in
          send(.updateValue(currencyValue: newValue.of(value.currencyWithRate)))
        }
      )
      .swipeActions(edge: .trailing) {
        Button {
          send(.openSelectCurrency(selectedCurrency: value.currency))
        } label: {
          Label("Change currency", systemSymbol: .arrowLeftArrowRight)
            .tint(Color.accentColor)
        }
      }
      .contextMenu {
        Button("Change currency") {
          send(.openSelectCurrency(selectedCurrency: value.currency))
        }
      }
    }
    .animation(.smooth, value: state.values)
  }
}

private struct CurrencyValueRow: View {
  let currencyValue: CurrencyValue
  let onValueChange: (Double) -> Void
  
  @FocusState private var isFocused: Bool

  var body: some View {
    let currency = currencyValue.currency
    let textFieldBinding = Binding(
      get: { currencyValue.value },
      set: { newValue in
        if newValue != currencyValue.value {
          onValueChange(newValue)
        }
      }
    )

    HStack {
      HStack {
        CurrencyFlagImage(for: currency, size: .medium)
        Text(currency.code.value)
      }
      .accessibilityElement(children: .ignore)
      .accessibilityLabel("Currency: \(currency.name)")
      Spacer()
      VStack(alignment: .trailing) {
        
        TextField(
          "Value",
          value: textFieldBinding,
          format: isFocused ? .number : .number.precision(.fractionLength(2))
        )
        .focused($isFocused)
        .font(.title2)
        .multilineTextAlignment(.trailing)
        #if os(iOS)
        .keyboardType(.decimalPad)
        #endif
        
        Text(currency.nameWithSymbol)
          .font(.caption)
      }
      .accessibilityElement(children: .ignore)
      .accessibilityLabel("\(currencyValue.value) \(currency.symbol)")
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
