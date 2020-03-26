//
//  UIAlertActionExtension.swift
//  DailyTodo
//
//  Created by ishida on 2020/02/26.
//  Copyright © 2020 ishida. All rights reserved.
//

import UIKit

extension UIAlertAction {
  static var ok: UIAlertAction {
    UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default)
  }
}
