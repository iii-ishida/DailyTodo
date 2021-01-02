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

  /// Watch modify events for Todos.
  public static func watchTodoList() -> AnyPublisher<[Todo], Error> {
    guard let userId = userId else {
      return authErrorFuture()
    }

    let sub = PassthroughSubject<[Todo], Error>()
    let listener = todoCollection(withUserId: userId).order(by: "order").addSnapshotListener { querySnapshot, error in
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

  /// Get next order for Todo list.
  public static func nextOrder() -> AnyPublisher<Int, Error> {
    guard let userId = userId else {
      return authErrorFuture()
    }

    return Future<Int, Error> { promise in
      todoCollection(withUserId: userId).order(by: "order", descending: true).limit(to: 1).getDocuments { querySnapshot, error in
        if let error = error {
          promise(.failure(error))
          return
        }

        guard let documents = querySnapshot?.documents, let todo = Todo(firebaseDocument: documents[0]) else {
          promise(.failure(APIError.unknown))
          return
        }

        promise(.success(todo.order + 1))
      }
    }.eraseToAnyPublisher()
  }

  /// Add a Todo.
  public static func addTodo(todo: Todo) -> AnyPublisher<Any, Error> {
    guard let userId = userId else {
      return authErrorFuture()
    }

    return Future<Any, Error> { promise in
      let data: [String: Any] = [
        "title": todo.title,
        "order": todo.order,
        "updatedAt": FieldValue.serverTimestamp(),
      ]

      todoCollection(withUserId: userId).addDocument(data: data) {
        if let error = $0 {
          promise(.failure(error))
        } else {
          promise(.success(true))
        }
      }
    }.eraseToAnyPublisher()
  }

  /// Update the title of a Todo.
  public static func updateTodo(withId id: String, title: String) -> AnyPublisher<Any, Error> {
    guard let userId = userId else {
      return authErrorFuture()
    }

    return Future<Any, Error> { promise in
      todoCollection(withUserId: userId).document(id).setData(["title": title, "updatedAt": FieldValue.serverTimestamp()], merge: true) {
        if let error = $0 {
          promise(.failure(error))
        } else {
          promise(.success(true))
        }
      }
    }.eraseToAnyPublisher()
  }

  /// reorder todo list and update the store.
  public static func updateReorderedTodoList(todoList: [Todo], from: Int, to: Int) -> AnyPublisher<Any, Error> {
    guard let userId = userId else {
      return authErrorFuture()
    }

    let reordered = Todo.reorderTodoList(todoList, from: from, to: to)

    let batch = db.batch()
    reordered.forEach { todo in
      let oldTodo = todoList.first { old in old.id == todo.id }
      guard let old = oldTodo, todo.order != old.order else { return }

      let doc = todoCollection(withUserId: userId).document(todo.id)
      batch.updateData(["order": todo.order], forDocument: doc)
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

  /// Delete a todo.
  public static func deleteTodo(_ todo: Todo) -> AnyPublisher<Any, Error> {
    guard let userId = userId else {
      return authErrorFuture()
    }

    return Future<Any, Error> { promise in
      todoCollection(withUserId: userId).document(todo.id).delete {
        if let error = $0 {
          promise(.failure(error))
        } else {
          promise(.success(true))
        }
      }
    }.eraseToAnyPublisher()
  }

  private static func todoCollection(withUserId userId: String) -> CollectionReference {
    db.collection("users/\(userId)/todos")
  }

  private static func authErrorFuture<T>() -> AnyPublisher<T, Error> {
    Future<T, Error> { $0(.failure(APIError.unauthorized)) }.eraseToAnyPublisher()
  }
}

extension DailyTodoAPI {
  /// Watch modify events for Todos.
  public static func watchDailyTodoList(date: Date) -> AnyPublisher<[DailyTodo], Error> {
    guard let userId = userId else {
      return authErrorFuture()
    }

    let sub = PassthroughSubject<[DailyTodo], Error>()
    let listener = dailyTodoCollection(withUserId: userId, date: date).order(by: "order").addSnapshotListener { querySnapshot, error in
      if let error = error {
        sub.send(completion: .failure(error))
        return
      }

      guard let documents = querySnapshot?.documents else { return }

      sub.send(DailyTodo.from(firestoreDocuments: documents))
    }

    return sub.handleEvents(
      receiveCompletion: { _ in listener.remove() },
      receiveCancel: { listener.remove() }
    ).eraseToAnyPublisher()
  }

  public static func createDailyTodoIfNeeded(date: Date) -> AnyPublisher<Any, Error> {
    guard let userId = userId else {
      return authErrorFuture()
    }

    return hasDailyTodo(withUserId: userId, date: date)
      .flatMap { hasDailyTodo -> AnyPublisher<Any, Error> in
        if hasDailyTodo {
          return Just<Any>(true).setFailureType(to: Error.self).eraseToAnyPublisher()
        } else {
          return copyDailyTodo(withUserId: userId, date: date)
        }
      }.eraseToAnyPublisher()
  }

  public static func doneDailyTodo(dailyTodo: DailyTodo) -> AnyPublisher<Any, Error> {
    guard let userId = userId else {
      return authErrorFuture()
    }

    return Future<Any, Error> { promise in
      dailyTodoCollection(withUserId: userId, date: dailyTodo.date).document(dailyTodo.id).setData(["done": true, "doneAt": FieldValue.serverTimestamp()], merge: true) {
        if let error = $0 {
          promise(.failure(error))
        } else {
          promise(.success(true))
        }
      }
    }.eraseToAnyPublisher()
  }

  public static func undoneDailyTodo(dailyTodo: DailyTodo) -> AnyPublisher<Any, Error> {
    guard let userId = userId else {
      return authErrorFuture()
    }

    return Future<Any, Error> { promise in
      dailyTodoCollection(withUserId: userId, date: dailyTodo.date).document(dailyTodo.id).setData(["done": false, "doneAt": NSNull()], merge: true) {
        if let error = $0 {
          promise(.failure(error))
        } else {
          promise(.success(true))
        }
      }
    }.eraseToAnyPublisher()
  }

  private static func copyDailyTodo(withUserId userId: String, date: Date) -> AnyPublisher<Any, Error> {
    let getTodos = Future<[Todo], Error> { promise in
      todoCollection(withUserId: userId).getDocuments { querySnapshot, error in
        if let error = error {
          promise(.failure(error))
          return
        }

        guard let documents = querySnapshot?.documents else {
          promise(.failure(APIError.unknown))
          return
        }
        promise(.success(Todo.from(firestoreDocuments: documents)))
      }
    }.eraseToAnyPublisher()

    return getTodos.flatMap { todos -> AnyPublisher<Any, Error> in
      let dailyTodos = DailyTodo.from(todos: todos, date: date)
      return putDailyTodos(withUserId: userId, date: date, dailyTodos: dailyTodos)
    }.eraseToAnyPublisher()
  }

  private static func putDailyTodos(withUserId userId: String, date: Date, dailyTodos: [DailyTodo]) -> AnyPublisher<Any, Error> {
    let batch = db.batch()
    let collection = dailyTodoCollection(withUserId: userId, date: date)
    dailyTodos.forEach {
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

  private static func hasDailyTodo(withUserId userId: String, date: Date) -> AnyPublisher<Bool, Error> {
    return Future<Bool, Error> { promise in
      dailyTodoCollection(withUserId: userId, date: date).limit(to: 1).getDocuments { querySnapshot, error in
        if let error = error {
          promise(.failure(error))
          return
        }

        let existsDailyTodo = querySnapshot?.documents.count ?? 0 > 0
        promise(.success(existsDailyTodo))
      }
    }.eraseToAnyPublisher()
  }

  private static func dailyTodoCollection(withUserId userId: String, date: Date) -> CollectionReference {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd"

    let yyyymmdd = formatter.string(from: date)
    return db.collection("users/\(userId)/daily/todos/\(yyyymmdd)")
  }
}
