import DateUtils
import Provider
import ConverterData
import CurrencyData
import HomePresentation
import RealAppStorage

final class SwiftlyModule: Module {

  var dependencies: [Module.Type] = [
    AppStorageModule.self,
    ConverterDataModule.self,
    CurrencyDataModule.self,
    DateUtilsModule.self,
    HomePresentationModule.self,
    ShortcutsModule.self
  ]
}
