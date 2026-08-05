import CurrencyDomain
import Design
import NukeUI
import Provider
import SFSafeSymbols
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
        .overlay(alignment: .bottom) {
          if let refreshError = state.refreshError {
            RefreshErrorBanner(error: refreshError) {
              viewModel.send(.refresh)
            }
          }
        }
        .refreshable {
          await viewModel.send(.refresh)
        }
        // Ticks the relative "Updated N ago" label. SwiftUI cancels this when the view goes away, which is
        // what keeps the ticker from outliving the screen.
        .task {
          await viewModel.syncUpdatedAt()
        }
        .toolbar {
          // Add Currency
          if state.canAddCurrency {
            ToolbarItem(placement: .primaryAction) {
              Button {
                viewModel.send(.openSelectCurrency(selectedCurrency: nil))
              } label: {
                Image(systemSymbol: .plus)
              }
            }
          }
          // Keyboard close button
#if canImport(UIKit)
          ToolbarItem(placement: .keyboard) {
            Button {
              UIApplication.shared.closeKeyboard()
            } label: {
              Image(systemSymbol: .keyboardChevronCompactDown)
            }
          }
#endif
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
            #if os(iOS)
            let updatedAtPlacement: ToolbarItemPlacement = .bottomBar
            #else
            let updatedAtPlacement: ToolbarItemPlacement = .automatic
            #endif
            ToolbarItem(placement: updatedAtPlacement) {
              Text("Updated \(updatedAt)")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
            }
          }
        }
        .sheet(isPresented: $viewModel.state.isSelectCurrencyOpen) {
          SelectCurrencySheet(
            uiModel: SelectCurrenciesUiModel(
              currencies: state.searchCurrencies,
              searchQuery: state.searchQuery,
              selectedCurrency: state.selectedCurrency,
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
            .tint(.accentColor)
        }
      }
      .swipeActions(edge: .leading) {
        if state.canRemoveCurrency {
          Button {
            send(.removeCurrency(currency: value.currency))
          } label: {
            Label("Remove currency", systemSymbol: .trash)
              .tint(.red)
          }
        }
      }
      .contextMenu {
        Button("Change currency") {
          send(.openSelectCurrency(selectedCurrency: value.currency))
        }
        if state.canRemoveCurrency {
          Button("Remove currency") {
            send(.removeCurrency(currency: value.currency))
          }
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

/// Shown when the rates on screen are the cached ones because the refresh failed.
///
/// The banner used to read "Refresh failed, showing cached data" whatever had gone wrong, which told the
/// user only that something had. The headline is now the typed reason — no connection, a refused API
/// key, an exhausted quota — and the fallback is demoted to the second line, where it belongs.
private struct RefreshErrorBanner: View {
  let error: ErrorModel
  let retry: () -> Void

  var body: some View {
    HStack(spacing: 12) {
      Image(systemSymbol: error.image)
        .imageScale(.large)

      VStack(alignment: .leading, spacing: 2) {
        Text(error.title)
          .font(.footnote.weight(.semibold))
        Text("Showing the rates saved on this device")
          .font(.caption2)
          .opacity(0.9)
      }
      .multilineTextAlignment(.leading)

      Spacer(minLength: 0)

      Button("Retry", action: retry)
        .font(.footnote.weight(.semibold))
        .buttonStyle(.plain)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 10)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(.red.opacity(0.9))
    .foregroundStyle(.white)
    .transition(.move(edge: .bottom).combined(with: .opacity))
  }
}

#Preview("Success") {
  Provider.setupPreview(viewModel: ConverterViewModel.samples.success)
  return NavigationStack { ConverterView() }
}

#Preview("Network error") {
  Provider.setupPreview(viewModel: ConverterViewModel.samples.networkError)
  return ConverterView()
}

#Preview("Storage error") {
  Provider.setupPreview(viewModel: ConverterViewModel.samples.storageError)
  return ConverterView()
}

#Preview("Refresh error") {
  Provider.setupPreview(viewModel: ConverterViewModel.samples.refreshError)
  return NavigationStack { ConverterView() }
}
