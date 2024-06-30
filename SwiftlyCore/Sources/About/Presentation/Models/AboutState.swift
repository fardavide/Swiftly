import Foundation
import SwiftlyUtils

public typealias AboutState = GenericLce<AboutUiModel>

public struct AboutUiModel: Equatable {
  let appName: String
  let appVersion: String
}
