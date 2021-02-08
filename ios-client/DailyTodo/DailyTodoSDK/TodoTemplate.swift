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
public struct TodoTemplate: Identifiable, Codable, Equatable {
  /// id.
  public let id: String

  /// titile.
  public let title: String

  /// order.
  public let order: Int

  /// u;datedAt.
  public let updatedAt: Date?

  /// initialize a Todo.
  public init(title: String, order: Int) {
    self.id = ""
    self.title = title
    self.order = order
    self.updatedAt = nil
  }

  private init(id: String, title: String, order: Int, updatedAt: Date?) {
    self.id = id
    self.title = title
    self.order = order
    self.updatedAt = updatedAt
  }

  /// Update the todo with a title.
  public func updated(withTitle newTitle: String) -> TodoTemplate {
    TodoTemplate(id: id, title: newTitle, order: order, updatedAt: updatedAt)
  }

  /// Hashes the essential components of this value by feeding them into the given hasher.
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

extension TodoTemplate {
  /// emtpy Todo.
  public static var empty: TodoTemplate {
    TodoTemplate(id: "", title: "", order: 0, updatedAt: nil)
  }
}

// MARK: Todo List
extension TodoTemplate {
  /// Reorder todoList.
  public static func reorderTodoList(_ todoList: [TodoTemplate], from: Int, to: Int) -> [TodoTemplate] {
    var reordered = todoList
    let todo = reordered.remove(at: from)
    reordered.insert(todo, at: to)

    return reordered.enumerated().map { arg in
      let (index, todo) = arg
      return TodoTemplate(id: todo.id, title: todo.title, order: index, updatedAt: todo.updatedAt)
    }
  }
}

// MARK: Firestore
extension TodoTemplate {
  static func from(firestoreDocuments documents: [DocumentSnapshot]) -> [TodoTemplate] {
    documents.compactMap { TodoTemplate(firebaseDocument: $0) }
  }

  init?(firebaseDocument document: DocumentSnapshot) {
    guard let data = document.data() else { return nil }

    id = document.documentID
    title = data["title"] as? String ?? ""
    order = data["order"] as? Int ?? 0
    updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue()
  }
}
