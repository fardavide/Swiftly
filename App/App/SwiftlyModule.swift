import CommonDate
import CommonProvider
import ConverterData
import ConverterPresentation
import CurrencyData

final class SwiftlyModule : Module {  
  init() {}

  var dependencies: [Module.Type] = [
    CommonDateModule.self,
    ConverterDataModule.self,
    ConverterPresentionModule.self,
    CurrencyDataModule.self
  ]
}
