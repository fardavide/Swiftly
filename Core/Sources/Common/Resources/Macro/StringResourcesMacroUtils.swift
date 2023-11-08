extension String {
  
  /// Capitalize the first character of the `String`
  var capitalizedFirst: String {
    prefix(1).capitalized + dropFirst()
  }
}
