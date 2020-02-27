//
//  DailyTodoSDK.swift
//  DailyTodoSDK
//
//  Created by ishida on 2020/02/24.
//  Copyright © 2020 ishida. All rights reserved.
//

import Firebase
import Foundation

/// the entry point of DailyTodoSDK.
public enum DailyTodoSDK {
  /// initialize DailyTodoSDK.
  public static func initialize() {
    FirebaseApp.configure()
  }
}
