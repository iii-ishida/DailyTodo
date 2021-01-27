//
//  Setting.swift
//  DailyTodo
//
//  Created by ishida on 2021/01/18.
//

import SwiftUI

struct Setting: View {
  @StateObject private var model = ViewModel()

  var body: some View {
    NavigationView {
      VStack {
        Spacer()
        Button(action: model.logout) {
          Text("ログアウト")
            .frame(maxWidth: .infinity, minHeight: 44.0)
            .foregroundColor(.white)
        }
        .background(Color.blue)
        .cornerRadius(4.0)

        Spacer().frame(height: 36.0)
      }
      .padding()
      .alert(
        isPresented: $model.showAlert,
        content: {
          Alert(title: Text("Error"), message: Text(model.error))
        })
    }
  }
}

private class ViewModel: ObservableObject {
  @Published var showAlert = false
  @Published var error = ""

  func logout() {
    showAlert = false

    do {
      try DailyTodoAuth.signOut()
    } catch {
      self.error = error.localizedDescription
      showAlert = true
    }
  }
}

struct Setting_Previews: PreviewProvider {
  static var previews: some View {
    Setting()
  }
}
