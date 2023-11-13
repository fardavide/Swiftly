import SwiftSyntax
import SwiftSyntaxMacros

public struct StringResourcesMacro: ExpressionMacro {
  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) throws -> ExprSyntax {
    guard let argument = node.argumentList.first?.expression else {
      throw Error.noArg
    }
    let identifier = if let memberAccess = argument.as(MemberAccessExprSyntax.self) {
      extractIdentifier(memberAccess: memberAccess)
    } else if let syntax = argument.as(FunctionCallExprSyntax.self) {
      try extractIdentifierWithArgs(syntax: syntax)
    } else {
      throw Error.unexpectedArg(type: "\(type(of: argument))")
    }

    return "LocalizedStringKey(\"\(raw: identifier)\")"
  }

  private static func extractIdentifier(
    memberAccess: MemberAccessExprSyntax
  ) -> String {
    let identifier = memberAccess.declName.baseName.text
    return identifier.capitalizedFirst
  }

  private static func extractIdentifierWithArgs(
    syntax: FunctionCallExprSyntax
  ) throws -> String {
    guard let memberAccess = syntax.calledExpression.as(MemberAccessExprSyntax.self) else {
      throw Error.unexpectedMemberType(type: "\(type(of: syntax))")
    }
    let identifier = extractIdentifier(memberAccess: memberAccess)
    let args = syntax.arguments.map { arg in
      if let literal = arg.expression.as(StringLiteralExprSyntax.self) {
        (arg.label, "\(literal.segments.first!)")
      } else {
        (arg.label, "\\(\(arg.expression))")
      }
    }
    let formattedLabels = args.compactMap { (label, _) in
      if let label = label {
        "\(label)".capitalizedFirst
      } else {
        nil
      }
    }.joined(separator: "")
    let formattedArgs = args.map(\.1).joined(separator: " ")

    // TODO: improve for non-trailing args
    return "\(identifier)\(formattedLabels): \(formattedArgs)"
  }

  enum Error: Swift.Error, CustomStringConvertible {
    case noArg
    case unexpectedArg(type: String)
    case unexpectedMemberType(type: String)
    case unxepectedMemberArg(type: String)

    var description: String {
      switch self {
      case .noArg: "No arguments provided"
      case let .unexpectedArg(type): "Unexpected argument type: \(type)"
      case let .unexpectedMemberType(type): "Unexpected member type: \(type)"
      case let .unxepectedMemberArg(type):  "Unexpected merber argument type: \(type)"
      }
    }
  }
}
