//
//  File.swift
//  
//
//  Created by Davide Giuseppe Farella on 29/10/23.
//

import CommonProvider

public final class CommonDateModule: Module {
  public init() {}
  
  public func register(on provider: Provider) {
    provider
      .register { RealGetCurrentDate() as GetCurrentDate }
  }
}
