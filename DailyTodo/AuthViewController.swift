//
//  AuthViewController.swift
//  DailyTodo
//
//  Created by ishida on 2020/02/24.
//  Copyright © 2020 ishida. All rights reserved.
//

import Combine
import DailyTodoSDK
import UIKit

class AuthViewController: UIViewController {
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var errorMessageLabel: UILabel!
  @IBOutlet weak var toggleModeButton: UIButton!
  @IBOutlet weak var submitButton: UIButton!

  private var cancellableSet: Set<AnyCancellable> = []
  private var signUpMode = false

  override func viewDidLoad() {
    super.viewDidLoad()

    errorMessageLabel.text = ""
    emailTextField.becomeFirstResponder()
  }

  @IBAction func onSubmit(_ sender: UIButton) {
    guard let email = self.emailTextField.text, let password = self.passwordTextField.text else { return }

    var publisher: AnyPublisher<String, Error>
    if signUpMode {
      publisher = DailyTodoSDK.signUp(withEmail: email, password: password)
    } else {
      publisher = DailyTodoSDK.signIn(withEmail: email, password: password)
    }

    publisher
      .receive(on: RunLoop.main)
      .sink(
        receiveCompletion: { result in
          switch result {
          case .failure(let error):
            self.errorMessageLabel.text = error.localizedDescription
          default:
            self.errorMessageLabel.text = ""
          }
        },
        receiveValue: { _ in }
      ).store(in: &cancellableSet)
  }

  @IBAction func onToggle(_ sender: UIButton) {
    signUpMode = !signUpMode
    configureView()
  }

  private func configureView() {
    if signUpMode {
      submitButton.setTitle("アカウント作成", for: .normal)
      toggleModeButton.setTitle("既存のアカウントでログインする", for: .normal)
    } else {
      submitButton.setTitle("ログイン", for: .normal)
      toggleModeButton.setTitle("アカウントを新規作成する", for: .normal)
    }
  }

}
