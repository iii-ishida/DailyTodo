//
//  DailyTodoRow.swift
//  DailyTodo
//
//  Created by ishida on 2020/09/22.
//

import SwiftUI

struct DailyTodoRow: View {
  var dailyTodo: DailyTodo
  @State private var isOn = false

  var body: some View {
    HStack {
      Toggle("", isOn: $isOn).labelsHidden()
      Text(dailyTodo.title)
      Spacer()
    }
  }
}

struct DailyTodoRow_Previews: PreviewProvider {
  static var previews: some View {
    DailyTodoRow(dailyTodo: DailyTodo(title: "some todo"))
  }
}
