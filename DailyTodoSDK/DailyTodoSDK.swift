//
//  DailyTodoSDK.swift
//  DailyTodoSDK
//
//  Created by ishida on 2020/02/24.
//  Copyright © 2020 ishida. All rights reserved.
//

import Combine
import Firebase
import Foundation

public enum AuthError: Error {
  case invalidEmail
  case emailAlreadyInUse
  case operationNotAllowed
  case weakPassword
  case unknown

  init(errorCode: String) {
    switch errorCode {
    case "FIRAuthErrorCodeInvalidEmail": self = .invalidEmail
    case "FIRAuthErrorCodeEmailAlreadyInUse": self = .emailAlreadyInUse
    case "FIRAuthErrorCodeOperationNotAllowed": self = .operationNotAllowed
    case "FIRAuthErrorCodeWeakPassword": self = .weakPassword
    default:
      self = .unknown
    }
  }
}

/// the entry point of DailyTodoSDK.
public enum DailyTodoSDK {
  private static var authStatePublisher: AnyPublisher<Bool, Never> {
    let pub = PassthroughSubject<Bool, Never>()
    Auth.auth().addStateDidChangeListener { _, user in
      pub.send(user != nil)
    }
    return pub.eraseToAnyPublisher()
  }

  /// initialize DailyTodoSDK.
  public static func initialize() {
    FirebaseApp.configure()
  }

  /// Creates and, on success, signs in a user with the given email address and password.
  ///
  /// - Parameters:
  ///   - email: The user's email address.
  ///   - password: The user's desired password.
  /// - Returns: A Publisher.
  public static func signUp(withEmail email: String, password: String) -> AnyPublisher<String, Error> {
    let future = Future<String, Error> { promise in
      Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
        if let error = error {
          promise(.failure(error))
        } else {
          promise(.success(result?.user.email ?? ""))
        }
      }
    }
    return AnyPublisher(future)
  }

  /// Signs in using an email address and password.
  ///
  /// - Parameters:
  ///   - email: The user's email address.
  ///   - password: The user's desired password.
  /// - Returns: A Publisher.
  public static func signIn(withEmail email: String, password: String) -> AnyPublisher<String, Error> {
    let future = Future<String, Error> { promise in
      Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
        if let error = error {
          promise(.failure(error))
        } else {
          promise(.success(result?.user.email ?? ""))
        }
      }
    }
    return AnyPublisher(future)
  }

  /// Signs out the current user.
  public static func signOut() throws {
    try Auth.auth().signOut()
  }

  /// Watch an auth state change.
  public static func watchAuthState() -> AnyPublisher<Bool, Never> {
    return authStatePublisher
  }
}
