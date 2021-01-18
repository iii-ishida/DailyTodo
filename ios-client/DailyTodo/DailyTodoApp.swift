//
//  DailyTodoApp.swift
//  DailyTodo
//
//  Created by ishida on 2020/09/21.
//

import SwiftUI

@main
struct DailyTodoApp: App {
  init() {
    DailyTodoSDK.initialize()
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
