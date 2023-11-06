import AppStorage
import ConverterStorage
import CurrencyStorage
import Foundation
import SwiftData

public final class RealAppStorage: AppStorage {

  static let instance = RealAppStorage()

  private let schema = Schema(
    [
      CurrencyDateSwiftDataModel.self,
      CurrencyRateSwiftDataModel.self,
      CurrencySwiftDataModel.self,
      FavoriteCurrenciesSwiftDataModel.self
    ],
    version: .init(0, 0, 1)
  )

  public let container: ModelContainer

  private init() {
    let configuration = ModelConfiguration(
      schema: schema,
      url: URL.documentsDirectory.appending(path: "/swiftly/data.store"),
      cloudKitDatabase: .automatic
    )

    do {
      container = try ModelContainer(
        for: schema,
        configurations: configuration
      )
    } catch {
      fatalError(error.localizedDescription)
    }
  }
}
