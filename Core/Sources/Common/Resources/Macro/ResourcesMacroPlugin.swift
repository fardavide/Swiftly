import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct ResourcesMacroPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    LocalizedStringKeyMacro.self,
    RawStringResourcesMacro.self
  ]
}
