import AppIntents
import Resources

struct ShortcutsProvider: AppShortcutsProvider {
  
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: ConvertIntent(),
      phrases: [
        "Convert with \(.applicationName)"
      ],
      shortTitle: "Convert currency",
      systemImageName: "coloncurrencysign"
    )
  }
}
