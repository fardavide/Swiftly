//
//  ViewModel.swift
//  App
//
//  Created by Davide Giuseppe Farella on 25/10/23.
//

import Foundation

public protocol ViewModel<Action, State>: ObservableObject {
  associatedtype Action
  associatedtype State
  
  var state: State { get }
  func send(_ action: Action)
}
