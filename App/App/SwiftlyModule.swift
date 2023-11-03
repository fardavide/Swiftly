import CommonDate
import CommonProvider
import ConverterData
import ConverterPresentation
import CurrencyData
import RealAppStorage

final class SwiftlyModule : Module {  
  init() {}

  var dependencies: [Module.Type] = [
    AppStorageModule.self,
    CommonDateModule.self,
    ConverterDataModule.self,
    ConverterPresentionModule.self,
    CurrencyDataModule.self
  ]
}
