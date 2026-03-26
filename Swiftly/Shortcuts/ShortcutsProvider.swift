import AppIntents

struct ShortcutsProvider: AppShortcutsProvider {
  
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: ConvertIntent(),
      phrases: [
        "Convert with \(.applicationName)",
        "Convert \(\.$fromCurrency) with \(.applicationName)",
        "Convert to \(\.$toCurrency) with \(.applicationName)"
      ],
      shortTitle: "Convert currency",
      systemImageName: "coloncurrencysign"
    )
  }
}
