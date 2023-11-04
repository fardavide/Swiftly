public enum DataError: Error {
  case network
  case storage(cause: StorageCause)
  case unknown
  
  public enum StorageCause {
    case noCache
    case unknown
  }
}
