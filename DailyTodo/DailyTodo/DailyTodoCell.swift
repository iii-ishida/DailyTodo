//
//  DailyTodoCell.swift
//  DailyTodo
//
//  Created by ishida on 2020/03/17.
//  Copyright © 2020 ishida. All rights reserved.
//

import DailyTodoSDK
import UIKit

protocol DailyTodoCellDelegate: class {
  func dailyTodoCell(_ cell: DailyTodoCell, didEditTodo dailyTodo: DailyTodo, done: Bool)
}

class DailyTodoCell: UITableViewCell {
  static let identifier = "DailyTodoCell"

  weak var delegate: DailyTodoCellDelegate? = nil

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var doneSwitch: UISwitch!

  var dailyTodo: DailyTodo! {
    didSet {
      titleLabel.text = dailyTodo.title
      doneSwitch.isOn = dailyTodo.done
    }
  }

  @IBAction func onToggleDone(_ sender: UISwitch) {
    self.delegate?.dailyTodoCell(self, didEditTodo: dailyTodo, done: sender.isOn)
  }
}
