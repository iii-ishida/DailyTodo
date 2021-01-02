//
//  DailyTodoList.swift
//  DailyTodo
//
//  Created by ishida on 2020/09/22.
//

import SwiftUI

struct DailyTodoList: View {
  var todos: [DailyTodo]

  var body: some View {
    List {
      ForEach(todos) { todo in
        DailyTodoRow(dailyTodo: todo)
      }
    }
  }
}

struct DailyTodoList_Previews: PreviewProvider {
  static var previews: some View {
    DailyTodoList(todos: [DailyTodo(title: "some todo"), DailyTodo(title: "some todo2"), DailyTodo(title: "some todo3")])
  }
}
