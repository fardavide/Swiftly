import DateUtils
import Provider
import ConverterData
import ConverterPresentation
import CurrencyData
import RealAppStorage

final class SwiftlyModule: Module {
  init() {}

  var dependencies: [Module.Type] = [
    AppStorageModule.self,
    ConverterDataModule.self,
    ConverterPresentionModule.self,
    CurrencyDataModule.self,
    DateUtilsModule.self
  ]
}
