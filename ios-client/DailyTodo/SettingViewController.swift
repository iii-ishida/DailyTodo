//
//  SettingViewController.swift
//  DailyTodo
//
//  Created by ishida on 2020/02/26.
//  Copyright © 2020 ishida. All rights reserved.
//

import DailyTodoSDK
import UIKit

class SettingViewController: UIViewController {

  @IBAction func onSignOut(_ sender: UIButton) {
    do {
      try DailyTodoAuth.signOut()
    } catch {
      let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
      alert.addAction(.ok)
      self.present(alert, animated: true, completion: nil)
    }
  }
}
