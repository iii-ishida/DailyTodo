//
//  DailyTodoList.swift
//  DailyTodo
//
//  Created by ishida on 2020/09/22.
//

import Combine
import SwiftUI

struct DailyTodoList: View {
  @StateObject private var model = ViewModel(date: Date())

  var body: some View {
    NavigationView {
      List {
        ForEach(model.list) { todo in
          DailyTodoRow(dailyTodo: todo)
        }
      }
      .navigationTitle(Text(model.date, style: .date))
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

private class ViewModel: ObservableObject {
  @Published var list: [DailyTodo] = []
  let date: Date

  private var cancellableSet: Set<AnyCancellable> = []

  init(date: Date) {
    self.date = date

    DailyTodoAPI.createDailyTodoIfNeeded(date: date).flatMap { _ in
      DailyTodoAPI.watchDailyTodoList(date: date)
    }
    .receive(on: RunLoop.main)
    .sink(
      receiveCompletion: { _ in },
      receiveValue: { self.list = $0 }
    )
    .store(in: &cancellableSet)
  }
}

struct DailyTodoList_Previews: PreviewProvider {
  static var previews: some View {
    DailyTodoList()
  }
}
