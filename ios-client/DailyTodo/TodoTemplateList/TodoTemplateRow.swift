//
//  EditTodoRow.swift
//  DailyTodo
//
//  Created by ishida on 2021/01/20.
//

import Combine
import SwiftUI

struct TodoTemplateRow: View {
  @ObservedObject private var model: ViewModel

  init(todoTemplate: TodoTemplate) {
    model = ViewModel(todoTemplate: todoTemplate)
  }

  var body: some View {
    TextField(model.isNew ? "新規作成" : "", text: $model.title, onCommit: model.updateTodo)
  }
}

private class ViewModel: ObservableObject {
  @Published var title: String
  let isNew: Bool

  private let todoTemplate: TodoTemplate
  private var cancellableSet: Set<AnyCancellable> = []

  init(todoTemplate: TodoTemplate) {
    self.todoTemplate = todoTemplate
    self.title = todoTemplate.title
    self.isNew = todoTemplate.id == ""
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
      DailyTodoAPI.updateTodoTemplate(withId: todoTemplate.id, title: title).sink(
        receiveCompletion: { _ in },
        receiveValue: { _ in }
      ).store(in: &cancellableSet)
    }
  }
}

struct TodoTemplateRow_Previews: PreviewProvider {
  static var previews: some View {
    TodoTemplateRow(todoTemplate: TodoTemplate(title: "some todo", order: 1))
  }
}
