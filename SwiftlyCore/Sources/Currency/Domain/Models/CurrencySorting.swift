public enum CurrencySorting {
  case alphabetical
  case favoritesFirst
}

public extension CurrencySorting {
  
  func toggle() -> CurrencySorting {
    switch self {
    case .alphabetical: .favoritesFirst
    case .favoritesFirst: .alphabetical
    }
  }
}
