//
//  DailyTodo.swift
//  DailyTodoSDK
//
//  Created by ishida on 2020/03/16.
//  Copyright © 2020 ishida. All rights reserved.
//

import Firebase
import Foundation

public struct DailyTodo {
  /// id.
  public let id: String

  /// titile.
  public let title: String

  /// order.
  public let order: Int

  /// done.
  private(set) public var done: Bool

  /// doneAt.
  private(set) public var doneAt: Date?

  private init(todo: Todo, yyyymmdd: String) {
    self.id = "\(yyyymmdd)-\(todo.id)"
    self.title = todo.title
    self.order = todo.order
    self.done = false
    self.doneAt = nil
  }

  public static func from(todos: [Todo], date: Date) -> [DailyTodo] {
    let yyyymmdd = Self.dateFormatter.string(from: date)
    return todos.map { DailyTodo(todo: $0, yyyymmdd: yyyymmdd) }
  }

  public mutating func done(doneAt: Date) {
    self.done = true
    self.doneAt = doneAt
  }

  private static var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd"
    return formatter
  }()
}

// MARK: Firestore
extension DailyTodo {
  init?(firebaseDocument document: DocumentSnapshot) {
    guard let data = document.data() else { return nil }

    id = document.documentID
    title = data["title"] as? String ?? ""
    order = data["order"] as? Int ?? 0
    done = data["done"] as? Bool ?? false
    doneAt = (data["doneAt"] as? Timestamp)?.dateValue()
  }

  var documentValue: [String: Any] {
    [
      "title": title,
      "order": order,
      "done": done,
      "doneAt": doneAt ?? NSNull(),
    ]
  }
}
