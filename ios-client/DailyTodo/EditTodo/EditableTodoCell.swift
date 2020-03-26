//
//  EditableTodoCell.swift
//  DailyTodo
//
//  Created by ishida on 2020/02/27.
//  Copyright © 2020 ishida. All rights reserved.
//

import DailyTodoSDK
import UIKit

protocol EditableTodoCellDelegate: class {
  func editableTodoCell(_ cell: EditableTodoCell, didEditTodo todo: Todo, newTitle: String)
}

class EditableTodoCell: UITableViewCell {
  static let identifier = "EditableTodoCell"
  @IBOutlet weak var titleTextField: UITextField!
  weak var delegate: EditableTodoCellDelegate? = nil

  var todo: Todo! {
    didSet {
      titleTextField.text = todo.title
      titleTextField.placeholder = isNew ? "新規作成" : todo.title
    }
  }

  var isNew = false {
    didSet {
      if isNew {
        titleTextField.placeholder = "新規作成"
      }
    }
  }

  @IBAction func onDoneEditing(_ sender: UITextField) {
    self.delegate?.editableTodoCell(self, didEditTodo: todo, newTitle: sender.text ?? "")
  }
}
