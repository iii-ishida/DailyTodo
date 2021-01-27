//
//  EditTodoList.swift
//  DailyTodo
//
//  Created by ishida on 2021/01/20.
//

import Combine
import SwiftUI
import UniformTypeIdentifiers

struct EditTodoList: View {
  @ObservedObject private var model = ViewModel()
  @State private var isEditable = false
  @State private var dragging: Todo?

  var body: some View {
    List {
      ForEach(model.list) { todo in
        EditTodoRow(todo: todo)
      }
      .onMove {
        guard let from = $0.first else { return }
        model.move(from: from, to: $1)
      }
      .onDelete {
        guard let index = $0.first else { return }
        model.deleteAt(index)
      }

      EditTodoRow(todo: Todo(title: "", order: model.list.count))
    }
    .navigationTitle("Edit Todo")
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarItems(trailing: EditButton())

  }
}

private class ViewModel: ObservableObject {
  @Published var list: [Todo] = []
  private var cancellableSet: Set<AnyCancellable> = []

  init() {
    DailyTodoAPI.watchTodoList()
      .sink(
        receiveCompletion: { _ in },
        receiveValue: { self.list = $0 }
      )
      .store(in: &cancellableSet)
  }

  func move(from: Int, to: Int) {
    DailyTodoAPI.updateReorderedTodoList(todoList: list, from: from, to: to).sink(
      receiveCompletion: { _ in },
      receiveValue: { _ in }
    ).store(in: &cancellableSet)
  }

  func deleteAt(_ index: Int) {
    let todo = list[index]

    DailyTodoAPI.deleteTodo(todo).sink(
      receiveCompletion: { _ in },
      receiveValue: { _ in }
    ).store(in: &cancellableSet)
  }
}

struct EditTodoList_Previews: PreviewProvider {
  static var previews: some View {
    EditTodoList()
  }
}
