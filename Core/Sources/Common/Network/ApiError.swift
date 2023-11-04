import Foundation

public enum ApiError: Error {
  case jsonError(JsonError)
  case unknown
}

public extension URLSession {
  
  func resultData<T: Decodable>(from url: URL) async -> Result<T, ApiError> {
    do {
      let (data, _) = try await data(from: url)
      return JSONDecoder().resultDecode(T.self, from: data)
        .mapError { .jsonError($0) }
    } catch {
      return .failure(.unknown)
    }
  }
}
