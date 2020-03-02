//
//  Todo.swift
//  DailyTodoSDK
//
//  Created by ishida on 2020/02/27.
//  Copyright © 2020 ishida. All rights reserved.
//

import Firebase
import Foundation

/// A Todo.
public struct Todo: Hashable {
  /// id.
  public let id: String

  /// titile.
  public let title: String

  /// done.
  public let done: Bool

  /// order.
  public let order: Int

  /// u;datedAt.
  public let updatedAt: Date?

  /// initialize a Todo.
  public init(title: String, order: Int, done: Bool = false) {
    self.id = ""
    self.title = title
    self.done = done
    self.order = order
    self.updatedAt = nil
  }

  private init(id: String, title: String, done: Bool, order: Int, updatedAt: Date?) {
    self.id = id
    self.title = title
    self.done = done
    self.order = order
    self.updatedAt = updatedAt
  }

  /// Hashes the essential components of this value by feeding them into the given hasher.
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

// MARK: Todo List
extension Todo {
  /// Reorder todoList.
  public static func reorderTodoList(_ todoList: [Todo], from: Int, to: Int) -> [Todo] {
    var reordered = todoList
    let todo = reordered.remove(at: from)
    reordered.insert(todo, at: to)

    return reordered.enumerated().map { arg in
      let (index, todo) = arg
      return Todo(id: todo.id, title: todo.title, done: todo.done, order: index, updatedAt: todo.updatedAt)
    }
  }
}

// MARK: Firestore
extension Todo {
  static func from(firestoreDocuments documents: [DocumentSnapshot]) -> [Todo] {
    documents.compactMap { Todo(firebaseDocument: $0) }
  }

  init?(firebaseDocument document: DocumentSnapshot) {
    guard let data = document.data() else { return nil }

    id = document.documentID
    title = data["title"] as? String ?? ""
    order = data["order"] as? Int ?? 0
    done = data["done"] as? Bool == true
    updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue()
  }

  var documentValue: [String: Any] {
    [
      "title": title,
      "order": order,
      "done": done,
      "updatedAt": FieldValue.serverTimestamp(),
    ]
  }
}
