//
//  AuthView.swift
//  DailyTodo
//
//  Created by ishida on 2020/10/05.
//

import Combine
import SwiftUI

struct AuthView: View {
  @StateObject private var model = ViewModel()

  let labelWidth: CGFloat = 78.0

  var body: some View {
    VStack {
      HStack {
        Text("email")
          .frame(width: labelWidth, alignment: .trailing)

        TextField("", text: $model.email)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .textContentType(.emailAddress)
      }

      HStack {
        Text("password")
          .frame(width: labelWidth, alignment: .trailing)

        SecureField("", text: $model.password)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .textContentType(.newPassword)
      }

      Text(model.error).foregroundColor(.red).font(.caption)

      Spacer().frame(height: 134)

      Button(action: model.submit) {
        Text(model.mode == .signIn ? "ログイン" : "アカウント作成")
          .frame(maxWidth: .infinity, minHeight: 44.0)
          .foregroundColor(.white)
      }
      .background(Color.blue)
      .cornerRadius(4.0)

      Spacer().frame(height: 32)

      Button(action: model.toggleMode) {
        HStack {
          Spacer()
          Text(model.mode == .signIn ? "アカウントを新規作成する" : "既存のアカウントでログインする")
            .font(.caption)
            .multilineTextAlignment(.trailing)
        }
      }

      Spacer()
    }.padding()
  }
}

private class ViewModel: ObservableObject {
  enum Mode {
    case signUp
    case signIn
  }

  var email = ""
  var password = ""
  @Published var mode: Mode = .signIn
  @Published var error = ""

  private var cancellableSet: Set<AnyCancellable> = []
  private var isValid: Bool {
    email != "" && password != ""
  }

  func toggleMode() {
    if mode == .signUp {
      mode = .signIn
    } else {
      mode = .signUp
    }
  }

  func submit() {
    guard isValid else { return }

    var publisher: AnyPublisher<String, Error>

    if mode == .signUp {
      publisher = DailyTodoAuth.signUp(withEmail: email, password: password)
    } else {
      publisher = DailyTodoAuth.signIn(withEmail: email, password: password)
    }

    publisher
      .receive(on: RunLoop.main)
      .sink(
        receiveCompletion: { result in
          switch result {
          case .failure(let error):
            self.error = error.localizedDescription
          default:
            self.error = ""
          }
        },
        receiveValue: { _ in }
      ).store(in: &cancellableSet)
  }
}

struct AuthView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      AuthView()
    }
  }
}
