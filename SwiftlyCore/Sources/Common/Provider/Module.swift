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
    let uniqueModules = ModuleRegistry.instance.findAllModulesRecursively(from: dependencies)
    for module in uniqueModules {
      module.register(on: provider)
    }
    register(on: provider)
  }
}

private class ModuleRegistry {
  static let instance = ModuleRegistry()

  private var modules = [ObjectIdentifier: Module]()

  private init() {}

  func findAllModulesRecursively(from modules: [Module.Type]) -> [Module] {
    var allModules: [Module] = []

    for moduleType in modules {
      let module = instantiate(moduleType)
      allModules.append(module)
      let dependentModules = findAllModulesRecursively(from: module.dependencies)
      allModules += dependentModules
    }

    return allModules
  }

  private func instantiate<T: Module>(_ moduleType: T.Type) -> T {
    if let existingModule = modules[ObjectIdentifier(moduleType)] as? T {
      return existingModule
    } else {
      let newModule = moduleType.init()
      modules[ObjectIdentifier(moduleType)] = newModule
      return newModule
    }
  }
}
