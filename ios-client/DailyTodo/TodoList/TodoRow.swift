//
//  DailyTodoRow.swift
//  DailyTodo
//
//  Created by ishida on 2020/09/22.
//

import Combine
import SwiftUI

struct TodoRow: View {
  private var model: ViewModel

  init(todo: Todo) {
    model = ViewModel(todo: todo)
  }

  var body: some View {
    HStack {
      Toggle("", isOn: Binding(get: { model.isDone }, set: model.toggle)).labelsHidden()
      Text(model.title)
      Spacer()
    }
  }
}

private class ViewModel: ObservableObject {
  let isDone: Bool
  let title: String

  private let todo: Todo
  private var cancellableSet: Set<AnyCancellable> = []

  init(todo: Todo) {
    self.todo = todo
    self.isDone = todo.done
    self.title = todo.title
  }

  func toggle(_ done: Bool) {
    if done {
      DailyTodoAPI.doneTodo(todo: todo)
        .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
        .store(in: &cancellableSet)
    } else {
      DailyTodoAPI.undoneTodo(todo: todo)
        .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
        .store(in: &cancellableSet)
    }
  }
}

struct TodoRow_Previews: PreviewProvider {
  static var previews: some View {
    TodoRow(todo: Todo(title: "some todo"))
  }
}
