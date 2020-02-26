//
//  RootViewController.swift
//  DailyTodo
//
//  Created by ishida on 2020/02/24.
//  Copyright © 2020 ishida. All rights reserved.
//

import Combine
import DailyTodoSDK
import UIKit

class RootViewController: UIViewController {
  private var cancellableSet: Set<AnyCancellable> = []

  override func viewDidLoad() {
    super.viewDidLoad()

    DailyTodoSDK.watchAuthState()
      .receive(on: RunLoop.main)
      .sink { isSignedIn in
        if isSignedIn {
          if self.presentedViewController is AuthViewController {
            self.dismiss(animated: true)
          }
        } else {
          self.performSegue(withIdentifier: "showAuth", sender: self)
        }
      }.store(in: &cancellableSet)
  }
}
