//
//  EditTodoRow.swift
//  DailyTodo
//
//  Created by ishida on 2021/01/20.
//

import Combine
import SwiftUI

struct EditTodoRow: View {
  @ObservedObject private var model: ViewModel

  init(todo: TodoTemplate) {
    model = ViewModel(todo: todo)
  }

  var body: some View {
    TextField(model.isNew ? "新規作成" : "", text: $model.title, onCommit: model.updateTodo)
  }
}

private class ViewModel: ObservableObject {
  @Published var title: String
  let isNew: Bool

  private let todo: TodoTemplate
  private var cancellableSet: Set<AnyCancellable> = []

  init(todo: TodoTemplate) {
    self.todo = todo
    self.title = todo.title
    self.isNew = todo.id == ""
  }

  func updateTodo() {
    if isNew {
      DailyTodoAPI.nextOrder()
        .map { TodoTemplate(title: self.title, order: $0) }
        .map { DailyTodoAPI.addTodoTemplate(template: $0) }
        .sink(
          receiveCompletion: { _ in },
          receiveValue: { _ in }
        ).store(in: &cancellableSet)
    } else {
      DailyTodoAPI.updateTodoTemplate(withId: todo.id, title: title).sink(
        receiveCompletion: { _ in },
        receiveValue: { _ in }
      ).store(in: &cancellableSet)
    }
  }
}

struct EditTodoRow_Previews: PreviewProvider {
  static var previews: some View {
    EditTodoRow(todo: TodoTemplate(title: "some todo", order: 1))
  }
}
