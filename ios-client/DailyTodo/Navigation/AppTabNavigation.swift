//
//  AppTabNavigation.swift
//  DailyTodo
//
//  Created by ishida on 2020/09/22.
//

import SwiftUI

struct AppTabNavigation: View {
  @State private var selection: Tab = .todo

  var body: some View {
    TabView(selection: $selection) {
      NavigationView {
        DailyTodoList()
      }
      .tabItem {
        Label("Todo", systemImage: "list.bullet")
          .accessibility(label: Text("Todo"))
      }
      .tag(Tab.todo)

      NavigationView {
        Setting()
      }
      .tabItem {
        Label("設定", systemImage: "gear")
          .accessibility(label: Text("設定"))
      }
      .tag(Tab.settings)
    }
  }
}

struct AppTabNavigation_Previews: PreviewProvider {
  static var previews: some View {
    AppTabNavigation()
  }
}

// MARK: - Tab

extension AppTabNavigation {
  enum Tab {
    case todo
    case edit
    case settings
  }
}
