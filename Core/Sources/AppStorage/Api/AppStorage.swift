import SwiftData

public protocol AppStorage {
  var container: ModelContainer { get }
}

public extension AppStorage {
  
  @discardableResult
  func withContext<T>(_ f: (ModelContext) async -> T) async -> T {
    let context = ModelContext(container)
    let result = await f(context)
    do {
      try context.save()
    } catch {
      fatalError(error.localizedDescription)
    }
    return result
  }
}

