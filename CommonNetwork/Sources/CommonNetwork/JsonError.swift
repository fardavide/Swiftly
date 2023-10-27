//
//  JsonError.swift
//  App
//
//  Created by Davide Giuseppe Farella on 25/10/23.
//

import Foundation

public enum JsonError: Error {
  case dataCorrupted(DecodingError.Context)
  case keyNotFound(CodingKey, DecodingError.Context)
  case typeMismatch(Any.Type, DecodingError.Context)
  case valueNotFound(Any.Type, DecodingError.Context)
  case unknown(Error)
}

public extension JSONDecoder {
  
  func resultDecode<T: Decodable>(
    _ type: T.Type,
    from data: Data
  ) -> Result<T, JsonError> {
    do {
      let decoded = try decode(T.self, from: data)
      return .success(decoded)
    } catch {
      switch error as? DecodingError {
        
      case .dataCorrupted(let context):
        return .failure(.dataCorrupted(context))
        
      case .keyNotFound(let key, let context):
        return .failure(.keyNotFound(key, context))
        
      case .typeMismatch(let type, let context):
        return .failure(.typeMismatch(type, context))
        
      case .valueNotFound(let type, let context):
        return .failure(.valueNotFound(type, context))
        
      default:
        return .failure(.unknown(error))
      }
    }
  }
}
