//
//  DailyTodo.swift
//  DailyTodoSDK
//
//  Created by ishida on 2020/03/16.
//  Copyright © 2020 ishida. All rights reserved.
//

import Firebase
import Foundation

public struct DailyTodo: Identifiable, Codable {
  /// id.
  public let id: String

  /// original Todo Id.
  public let origintlId: String

  /// date.
  public let date: Date

  /// titile.
  public let title: String

  /// order.
  public let order: Int

  /// done.
  private(set) public var done: Bool

  /// doneAt.
  private(set) public var doneAt: Date?

  private init(template: TodoTemplate, date: Date) {
    let yyyymmdd = Self.dateFormatter.string(from: date)

    self.id = "\(yyyymmdd)-\(template.id)"
    self.origintlId = template.id
    self.date = date
    self.title = template.title
    self.order = template.order
    self.done = false
    self.doneAt = nil
  }

  init(title: String) {
    self.id = title
    self.origintlId = title
    self.date = Date()
    self.title = title
    self.order = 0
    self.done = false
    self.doneAt = nil
  }

  public static func from(templates: [TodoTemplate], date: Date) -> [DailyTodo] {
    return templates.map { DailyTodo(template: $0, date: date) }
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
    origintlId = data["originalId"] as? String ?? ""
    date = (data["date"] as! Timestamp).dateValue()
    title = data["title"] as? String ?? ""
    order = data["order"] as? Int ?? 0
    done = data["done"] as? Bool ?? false
    doneAt = (data["doneAt"] as? Timestamp)?.dateValue()
  }

  static func from(firestoreDocuments documents: [DocumentSnapshot]) -> [DailyTodo] {
    documents.compactMap { DailyTodo(firebaseDocument: $0) }
  }
}
