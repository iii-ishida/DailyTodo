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

  init(dailyTodo: DailyTodo) {
    model = ViewModel(dailyTodo: dailyTodo)
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

  private let dailyTodo: DailyTodo
  private var cancellableSet: Set<AnyCancellable> = []

  init(dailyTodo: DailyTodo) {
    self.dailyTodo = dailyTodo
    self.isDone = dailyTodo.done
    self.title = dailyTodo.title
  }

  func toggle(_ done: Bool) {
    if done {
      DailyTodoAPI.doneDailyTodo(dailyTodo: dailyTodo)
        .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
        .store(in: &cancellableSet)
    } else {
      DailyTodoAPI.undoneDailyTodo(dailyTodo: dailyTodo)
        .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
        .store(in: &cancellableSet)
    }
  }
}

struct DailyTodoRow_Previews: PreviewProvider {
  static var previews: some View {
    TodoRow(dailyTodo: DailyTodo(title: "some todo"))
  }
}
