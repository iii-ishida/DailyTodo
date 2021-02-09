//
//  DailyTodoAPI.swift
//  DailyTodoSDK
//
//  Created by ishida on 2020/02/27.
//  Copyright © 2020 ishida. All rights reserved.
//

import Combine
import Firebase
import Foundation

public enum DailyTodoAPI {
  private enum APIError: Error {
    case unauthorized
    case unknown
  }

  private static let db = Firestore.firestore()

  private static var userId: String? {
    DailyTodoAuth.userId
  }

  /// Watch modify events for TodoTemplates.
  public static func watchTodoTemplateList() -> AnyPublisher<[TodoTemplate], Error> {
    guard let userId = userId else {
      return authErrorFuture()
    }

    let sub = PassthroughSubject<[TodoTemplate], Error>()
    let listener = todoTemplateCollection(withUserId: userId).order(by: "order").addSnapshotListener { querySnapshot, error in
      if let error = error {
        sub.send(completion: .failure(error))
        return
      }

      guard let documents = querySnapshot?.documents else { return }

      sub.send(TodoTemplate.from(firestoreDocuments: documents))
    }

    return sub.handleEvents(
      receiveCompletion: { _ in listener.remove() },
      receiveCancel: { listener.remove() }
    ).eraseToAnyPublisher()
  }

  /// Get next order for TodoTemplates list.
  public static func nextOrder() -> AnyPublisher<Int, Error> {
    guard let userId = userId else {
      return authErrorFuture()
    }

    return Future<Int, Error> { promise in
      todoTemplateCollection(withUserId: userId).order(by: "order", descending: true).limit(to: 1).getDocuments { querySnapshot, error in
        if let error = error {
          promise(.failure(error))
          return
        }

        guard let documents = querySnapshot?.documents, let todo = TodoTemplate(firebaseDocument: documents[0]) else {
          promise(.failure(APIError.unknown))
          return
        }

        promise(.success(todo.order + 1))
      }
    }.eraseToAnyPublisher()
  }

  /// Add a TodoTemplate.
  public static func addTodoTemplate(template: TodoTemplate) -> AnyPublisher<Any, Error> {
    guard let userId = userId else {
      return authErrorFuture()
    }

    return Future<Any, Error> { promise in
      let data: [String: Any] = [
        "title": template.title,
        "order": template.order,
        "updatedAt": FieldValue.serverTimestamp(),
      ]

      todoTemplateCollection(withUserId: userId).addDocument(data: data) {
        if let error = $0 {
          promise(.failure(error))
        } else {
          promise(.success(true))
        }
      }
    }.eraseToAnyPublisher()
  }

  /// Update the title of a TodoTemplate.
  public static func updateTodoTemplate(withId id: String, title: String) -> AnyPublisher<Any, Error> {
    guard let userId = userId else {
      return authErrorFuture()
    }

    return Future<Any, Error> { promise in
      todoTemplateCollection(withUserId: userId).document(id).setData(["title": title, "updatedAt": FieldValue.serverTimestamp()], merge: true) {
        if let error = $0 {
          promise(.failure(error))
        } else {
          promise(.success(true))
        }
      }
    }.eraseToAnyPublisher()
  }

  /// reorder todoTemplateList list and update the store.
  public static func updateReorderedTodoTemplateList(todoTemplateList: [TodoTemplate], from: Int, to: Int) -> AnyPublisher<Any, Error> {
    guard let userId = userId else {
      return authErrorFuture()
    }

    let reordered = TodoTemplate.reorderTodoList(todoTemplateList, from: from, to: to)

    let batch = db.batch()
    reordered.forEach { template in
      let oldTodo = todoTemplateList.first { old in old.id == template.id }
      guard let old = oldTodo, template.order != old.order else { return }

      let doc = todoTemplateCollection(withUserId: userId).document(template.id)
      batch.updateData(["order": template.order], forDocument: doc)
    }

    return Future<Any, Error> { promise in
      batch.commit {
        if let error = $0 {
          promise(.failure(error))
        } else {
          promise(.success(true))
        }
      }
    }.eraseToAnyPublisher()
  }

  /// Delete a todoTemplate.
  public static func deleteTodoTemplate(_ todoTemplate: TodoTemplate) -> AnyPublisher<Any, Error> {
    guard let userId = userId else {
      return authErrorFuture()
    }

    return Future<Any, Error> { promise in
      todoTemplateCollection(withUserId: userId).document(todoTemplate.id).delete {
        if let error = $0 {
          promise(.failure(error))
        } else {
          promise(.success(true))
        }
      }
    }.eraseToAnyPublisher()
  }

  private static func todoTemplateCollection(withUserId userId: String) -> CollectionReference {
    db.collection("users/\(userId)/todos")
  }

  private static func authErrorFuture<T>() -> AnyPublisher<T, Error> {
    Future<T, Error> { $0(.failure(APIError.unauthorized)) }.eraseToAnyPublisher()
  }
}

extension DailyTodoAPI {
  /// Watch modify events for Todos.
  public static func watchTodoList(date: Date) -> AnyPublisher<[Todo], Error> {
    guard let userId = userId else {
      return authErrorFuture()
    }

    let sub = PassthroughSubject<[Todo], Error>()
    let listener = todoCollection(withUserId: userId, date: date).order(by: "order").addSnapshotListener { querySnapshot, error in
      if let error = error {
        sub.send(completion: .failure(error))
        return
      }

      guard let documents = querySnapshot?.documents else { return }

      sub.send(Todo.from(firestoreDocuments: documents))
    }

    return sub.handleEvents(
      receiveCompletion: { _ in listener.remove() },
      receiveCancel: { listener.remove() }
    ).eraseToAnyPublisher()
  }

  public static func createTodoIfNeeded(date: Date) -> AnyPublisher<Any, Error> {
    guard let userId = userId else {
      return authErrorFuture()
    }

    return todoExists(withUserId: userId, date: date)
      .flatMap { exists -> AnyPublisher<Any, Error> in
        if exists {
          return Just<Any>(true).setFailureType(to: Error.self).eraseToAnyPublisher()
        } else {
          return copyTodo(withUserId: userId, date: date)
        }
      }.eraseToAnyPublisher()
  }

  public static func doneTodo(todo: Todo) -> AnyPublisher<Any, Error> {
    guard let userId = userId else {
      return authErrorFuture()
    }

    return Future<Any, Error> { promise in
      todoCollection(withUserId: userId, date: todo.date).document(todo.id).setData(["done": true, "doneAt": FieldValue.serverTimestamp()], merge: true) {
        if let error = $0 {
          promise(.failure(error))
        } else {
          promise(.success(true))
        }
      }
    }.eraseToAnyPublisher()
  }

  public static func undoneTodo(todo: Todo) -> AnyPublisher<Any, Error> {
    guard let userId = userId else {
      return authErrorFuture()
    }

    return Future<Any, Error> { promise in
      todoCollection(withUserId: userId, date: todo.date).document(todo.id).setData(["done": false, "doneAt": NSNull()], merge: true) {
        if let error = $0 {
          promise(.failure(error))
        } else {
          promise(.success(true))
        }
      }
    }.eraseToAnyPublisher()
  }

  private static func copyTodo(withUserId userId: String, date: Date) -> AnyPublisher<Any, Error> {
    let getTemplates = Future<[TodoTemplate], Error> { promise in
      todoTemplateCollection(withUserId: userId).getDocuments { querySnapshot, error in
        if let error = error {
          promise(.failure(error))
          return
        }

        guard let documents = querySnapshot?.documents else {
          promise(.failure(APIError.unknown))
          return
        }
        promise(.success(TodoTemplate.from(firestoreDocuments: documents)))
      }
    }.eraseToAnyPublisher()

    return getTemplates.flatMap { templates -> AnyPublisher<Any, Error> in
      let todos = Todo.from(templates: templates, date: date)
      return putTodos(withUserId: userId, date: date, todos: todos)
    }.eraseToAnyPublisher()
  }

  private static func putTodos(withUserId userId: String, date: Date, todos: [Todo]) -> AnyPublisher<Any, Error> {
    let batch = db.batch()
    let collection = todoCollection(withUserId: userId, date: date)
    todos.forEach {
      let ref = collection.document($0.id)
      let data: [String: Any] = [
        "originalId": $0.origintlId,
        "title": $0.title,
        "date": $0.date,
        "order": $0.order,
        "done": $0.done,
        "doneAt": $0.doneAt ?? NSNull(),
      ]
      batch.setData(data, forDocument: ref)
    }

    return Future<Any, Error> { promise in
      batch.commit { error in
        if let error = error {
          promise(.failure(error))
        } else {
          promise(.success(true))
        }
      }
    }.eraseToAnyPublisher()
  }

  private static func todoExists(withUserId userId: String, date: Date) -> AnyPublisher<Bool, Error> {
    return Future<Bool, Error> { promise in
      todoCollection(withUserId: userId, date: date).limit(to: 1).getDocuments { querySnapshot, error in
        if let error = error {
          promise(.failure(error))
          return
        }

        let exists = querySnapshot?.documents.count ?? 0 > 0
        promise(.success(exists))
      }
    }.eraseToAnyPublisher()
  }

  private static func todoCollection(withUserId userId: String, date: Date) -> CollectionReference {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd"

    let yyyymmdd = formatter.string(from: date)
    return db.collection("users/\(userId)/daily/todos/\(yyyymmdd)")
  }
}
