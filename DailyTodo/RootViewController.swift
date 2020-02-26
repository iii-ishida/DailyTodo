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
  @IBOutlet weak var authContainerView: UIView!

  override func viewDidLoad() {
    super.viewDidLoad()

    DailyTodoSDK.watchAuthState()
      .receive(on: RunLoop.main)
      .sink { isSignedIn in
        self.authContainerView.isHidden = isSignedIn
      }.store(in: &cancellableSet)
  }
}
