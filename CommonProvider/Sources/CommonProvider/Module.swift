//
//  File.swift
//  
//
//  Created by Davide Giuseppe Farella on 28/10/23.
//

import Foundation

/*
 Defines how dependencies are registered to `Provider`
 Override `dependencies` to declare `Module`s to depend upon
 Override `register` to register additional dependencies on the `Module`
 
 Examples:
 ```swift
class PresentationModule: Module {
 
  var dependencies = [
    DomainModule.self
  ]
 
  func register(on provider: Provider) {
    provider
      .register { MyViewModel() }
      .register { RealSomethingElse() as SomethingElse }
  }
}
 ```
 */
public protocol Module {
  
  var dependencies: [Module.Type] { get }
  
  init()
  
  func register(on provider: Provider)
  func start(with provider: Provider)
}

public extension Module {
  
  var dependencies: [Module.Type] { [] }
  
  func register(on provider: Provider) {}
  
  func start(with provider: Provider) {
    for dependency in dependencies {
      dependency.init().register(on: provider)
    }
    register(on: provider)
  }
}
