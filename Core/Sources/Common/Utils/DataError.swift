public enum DataError: Equatable, Error {
  case network
  case storage(cause: StorageCause)
  case unknown
  
  public enum StorageCause {
    case noCache
    case unknown
  }
}
