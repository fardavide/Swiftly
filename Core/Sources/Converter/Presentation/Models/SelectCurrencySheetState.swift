import CurrencyDomain
import SwiftUI

enum SelectCurrencySheetState: Equatable {
  case close
  case open(selectedCurrency: Currency)
}

extension SelectCurrencySheetState {
  func requireSelectedCurrency() -> Currency {
    switch self {
    case .close: fatalError("Required open, but was close")
    case let .open(selectedCurrency): selectedCurrency
    }
  }
}

extension Binding<SelectCurrencySheetState> {
  var isOpen: Binding<Bool> {
    Binding<Bool>(get: { wrappedValue != .close }, set: { _ in })
  }
}
