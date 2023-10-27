//
//  File.swift
//  
//
//  Created by Davide Giuseppe Farella on 27/10/23.
//

import CommonProvider

public func converterPresentationRegistry(provider: Provider) {  
  provider
    .register { ConverterViewModel(repository: provider.get()) }
}
