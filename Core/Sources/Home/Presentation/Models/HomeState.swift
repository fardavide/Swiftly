import CurrencyDomain

struct HomeState {
  var isAboutOpen: Bool
}

extension HomeState {
  static let initial = HomeState(
    isAboutOpen: false
  )
}
