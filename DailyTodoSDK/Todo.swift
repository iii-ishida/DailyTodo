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

  /// Hashes the essential components of this value by feeding them into the given hasher.
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
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
