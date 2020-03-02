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

  /// Add a Todo.
  public static func addTodo(todo: Todo) -> AnyPublisher<Any, Error> {
    guard let userId = userId else {
      return authErrorFuture()
    }

    return Future<Any, Error> { promise in
      todoCollection(withUserId: userId).addDocument(data: todo.documentValue) {
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

  private static func todoCollection(withUserId userId: String) -> CollectionReference {
    db.collection("users/\(userId)/todos")
  }

  private static func authErrorFuture<T>() -> AnyPublisher<T, Error> {
    Future<T, Error> { $0(.failure(APIError.unauthorized)) }.eraseToAnyPublisher()
  }
}
