import SwiftlyUtils

/// Keys for SF symbols
/// Use with `image` func to resolve a `String`
public enum SfKey {
  case arrowLeftArrowRight
  case star
  case starSlash
  case xmarkCircleFill
}

/// Resolves a `String` that identifies the SF symbol from given `key`
public func image(_ key: SfKey) -> String {
  let name = "\(key)"
  return name.dotCase
}
