import SwiftSyntax
import SwiftSyntaxMacros

public struct LocalizedStringKeyMacro: ExpressionMacro {
  
  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) throws -> ExprSyntax {
    let identifier = try RawStringResourcesMacro.expansion(of: node, in: context)
    return "LocalizedStringKey(\(raw: identifier))"
  }
}
