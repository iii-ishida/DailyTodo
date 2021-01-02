//
//  ContentView.swift
//  DailyTodo
//
//  Created by ishida on 2020/09/21.
//

import Combine
import SwiftUI

struct ContentView: View {
  @ObservedObject private var model = ViewModel()

  var body: some View {
    if model.isSignedIn {
      AppTabNavigation()
    } else {
      AuthView()
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

private class ViewModel: ObservableObject {
  @Published var isSignedIn = false
  private var cancellableSet: Set<AnyCancellable> = []

  init() {
    DailyTodoSDK.initialize()
    DailyTodoAuth.watchAuthState().assign(to: \.isSignedIn, on: self).store(in: &cancellableSet)
  }
}
