//
//  DailyTodo.swift
//  DailyTodoSDK
//
//  Created by ishida on 2020/03/16.
//  Copyright © 2020 ishida. All rights reserved.
//

import Firebase
import Foundation

public struct DailyTodo: Hashable {
  /// id.
  public let id: String

  public let date: Date

  /// titile.
  public let title: String

  /// order.
  public let order: Int

  /// done.
  private(set) public var done: Bool

  /// doneAt.
  private(set) public var doneAt: Date?

  private init(todo: Todo, date: Date) {
    let yyyymmdd = Self.dateFormatter.string(from: date)

    self.id = "\(yyyymmdd)-\(todo.id)"
    self.date = date
    self.title = todo.title
    self.order = todo.order
    self.done = false
    self.doneAt = nil
  }

  public static func from(todos: [Todo], date: Date) -> [DailyTodo] {
    return todos.map { DailyTodo(todo: $0, date: date) }
  }

  public mutating func done(doneAt: Date) {
    self.done = true
    self.doneAt = doneAt
  }

  /// Hashes the essential components of this value by feeding them into the given hasher.
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
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
    date = (data["date"] as! Timestamp).dateValue()
    title = data["title"] as? String ?? ""
    order = data["order"] as? Int ?? 0
    done = data["done"] as? Bool ?? false
    doneAt = (data["doneAt"] as? Timestamp)?.dateValue()
  }

  static func from(firestoreDocuments documents: [DocumentSnapshot]) -> [DailyTodo] {
    documents.compactMap { DailyTodo(firebaseDocument: $0) }
  }

  var documentValue: [String: Any] {
    [
      "title": title,
      "date": date,
      "order": order,
      "done": done,
      "doneAt": doneAt ?? NSNull(),
    ]
  }
}
