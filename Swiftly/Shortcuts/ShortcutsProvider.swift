import AppIntents
import Resources

struct ShortcutsProvider: AppShortcutsProvider {
  
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: ConvertIntent(),
      phrases: [
        "Convert with \(.applicationName)",
        "Convert \(\.$amount) \(\.$fromCurrency) to \(\.$toCurrency)"
      ],
      shortTitle: "Convert currency",
      systemImageName: "coloncurrencysign"
    )
  }
}
