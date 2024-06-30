import Foundation

func getFlagUrl(for code: CurrencyCode, size: FlagSize) -> URL? {
  let url = baseUrl
    .replacing(widthPlaceholder, with: "\(size)")
    .replacing(codePlaceholder, with: code.value.lowercased())
  return URL(string: url)
}

enum FlagSize {
  case w150
  case w300
}

private let widthPlaceholder = "{w}"
private let codePlaceholder = "{c}"
private let baseUrl =
"https://github.com/fardavide/Swiftly/blob/main/Media/Flags/png-\(widthPlaceholder)/\(codePlaceholder).png?raw=true"
