import CurrencyDomain
import SwiftUI

struct SelectCurrencySheet: View {
  let currencies: [Currency]
  let onCurrencySelected: (Currency) -> ()
  
  var body: some View {
    List(currencies, id: \.code) { currency in
      CurrencyRow(currency: currency)
        .onTapGesture { onCurrencySelected(currency) }
    }
  }
}

private struct CurrencyRow: View {
  let currency: Currency
  
  var body: some View {
    HStack {
      Text(currency.flag)
        .font(.title)
      Text(currency.code.value)
      Spacer()
      Text(currency.nameWithSymbol)
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel("Currency: \(currency.name)")
  }
}

#Preview {
  SelectCurrencySheet(
    currencies: Currency.samples.all(),
    onCurrencySelected: { _ in }
  )
}
