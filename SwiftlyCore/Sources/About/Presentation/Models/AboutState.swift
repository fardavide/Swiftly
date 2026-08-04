import Foundation
import SwiftlyUtils

public typealias AboutState = GenericLce<AboutUiModel>

public struct AboutUiModel: Equatable, Sendable {
  let appName: String
  let appVersion: String
}
