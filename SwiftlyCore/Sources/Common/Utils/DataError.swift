public enum DataError: Equatable, Error {
  case network(cause: NetworkCause)
  case storage(cause: StorageCause)
  case unknown

  public enum NetworkCause {
    case json
    case unknown
  }
  
  public enum StorageCause {
    case noCache
    case unknown
  }
}
