import Foundation

public extension String {

  /// Capitalize the first character of the `String`, leaving the rest unchanged
  /// Example:
  /// ```swift
  /// "hello world".capitalizedFirst // "Hello world"
  /// "gitHub".capitalizedFirst // "GitHub"
  /// ```
  var capitalizedFirst: String {
    prefix(1).capitalized + dropFirst()
  }
  
  /// Transform the `String` into dot.case
  /// Example:
  /// ```swift
  /// "helloWorld".dotCase // "hello.world"
  /// ```
  ///
  /// Currently supported input cases:
  /// * camelCase
  var dotCase: String {
    var result = ""
    
    for (index, character) in self.enumerated() {
      if let scalar = UnicodeScalar(String(character)) {
        if CharacterSet.uppercaseLetters.contains(scalar) && index != 0 {
          result.append(".")
        }
      }
      result.append(character)
    }
    
    return result.lowercased()
  }
}
