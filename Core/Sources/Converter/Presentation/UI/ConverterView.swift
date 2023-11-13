import CurrencyDomain
import NukeUI
import Provider
import Resources
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
          state: state,
          actions: ContentView.Actions(
            changeCurrency: { prev, new in
              viewModel.send(.changeCurrency(prev: prev, new: new))
            },
            searchCurrencies: { query in
              viewModel.send(.searchCurrencies(query: query))
            },
            setSorting: { sorting in
              viewModel.send(.setSorting(sorting))
            },
            updateValue: { currencyValue in
              viewModel.send(.updateValue(currencyValue: currencyValue))
            }
          )
        )
      }
    }
  }
}

private struct ContentView: View {
  let state: ConverterState
  let actions: Actions

  @State private var isShowingSheet = false
  @State private var selectedCurrencyValue: CurrencyValue?

  var body: some View {
    List(state.values, id: \.currency) { value in
      CurrencyValueRow(
        value: value,
        onValueChange: { newValue in
          actions.updateValue(newValue.of(value.currencyWithRate))
        }
      )
      .swipeActions(edge: .trailing) {
        Button {
          selectedCurrencyValue = value
          isShowingSheet = true
        } label: {
          Label(#string(.changeCurrency), systemImage: image(.arrowLeftArrowRight))
            .tint(Color.accentColor)
        }
      }
      .contextMenu {
        Button(#string(.changeCurrency)) {
          selectedCurrencyValue = value
          isShowingSheet = true
        }
      }
    }
    .sheet(isPresented: $isShowingSheet) {
      SelectCurrencySheet(
        uiModel: SelectCurrenciesUiModel(
          currencies: state.searchCurrencies,
          sorting: state.sorting
        ),
        actions: SelectCurrencySheet.Actions(
          dismiss: {
            actions.searchCurrencies("")
            isShowingSheet = false
          },
          selectCurrency: { newCurrency in
            actions.changeCurrency(selectedCurrencyValue!.currency, newCurrency)
            isShowingSheet = false
          },
          searchCurrencies: actions.searchCurrencies,
          setSorting: actions.setSorting
        )
      )
      #if os(macOS)
      .frame(idealWidth: 400, idealHeight: 500)
      #endif
    }
  }
  
  struct Actions {
    let changeCurrency: (_ prev: Currency, _ new: Currency) -> Void
    let searchCurrencies: (_ query: String) -> Void
    let setSorting: (_ currencyStoring: CurrencySorting) -> Void
    let updateValue: (CurrencyValue) -> Void
  }
}

private struct CurrencyValueRow: View {
  let value: CurrencyValue
  let onValueChange: (Double) -> Void

  var body: some View {
    let currency = value.currency
    let textFieldBinding = Binding(get: { value.value }, set: onValueChange)

    HStack {
      HStack {
        LazyImage(request: ImageRequest(url: currency.flagUrl))
          .frame(width: 35, height: 30)
          .clipShape(.capsule)
        Text(currency.code.value)
      }
      .accessibilityElement(children: .ignore)
      .accessibilityLabel(#string(.currencyWith(name: currency.name)))
      Spacer()
      VStack(alignment: .trailing) {
        TextField(
          #string(.value),
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
