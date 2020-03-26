//
//  DailyTodoViewController.swift
//  DailyTodo
//
//  Created by ishida on 2020/03/17.
//  Copyright © 2020 ishida. All rights reserved.
//

import Combine
import DailyTodoSDK
import UIKit

class DailyTodoViewController: UIViewController {
  enum Section: Int {
    case main = 0
  }

  @IBOutlet weak var tableView: UITableView!
  private var dataSource: UITableViewDiffableDataSource<Section, DailyTodo>!
  private var cancellableSet: Set<AnyCancellable> = []

  override func viewDidLoad() {
    super.viewDidLoad()

    configureDataSource()
    watchTodoList(date: Date())
  }
}

// MARK: - Private Functions
extension DailyTodoViewController {

  private func configureDataSource() {
    dataSource = UITableViewDiffableDataSource<Section, DailyTodo>(tableView: tableView) { (tableView, indexPath, todo) in
      guard let cell = tableView.dequeueReusableCell(withIdentifier: DailyTodoCell.identifier, for: indexPath) as? DailyTodoCell else {
        fatalError("Cannot create new cell")
      }

      cell.delegate = self
      cell.dailyTodo = todo

      return cell
    }
    dataSource.defaultRowAnimation = .fade
  }

  private func watchTodoList(date: Date) {
    DailyTodoAPI.createDailyTodoIfNeeded(date: date).flatMap { _ in
      DailyTodoAPI.watchDailyTodoList(date: date)
    }
      .map {
        var snapshot = NSDiffableDataSourceSnapshot<Section, DailyTodo>()
        snapshot.appendSections([.main])
        snapshot.appendItems($0, toSection: .main)
        return snapshot
      }
      .receive(on: RunLoop.main)
      .sink(
        receiveCompletion: { _ in },
        receiveValue: { self.dataSource.apply($0, animatingDifferences: true) }
      )
      .store(in: &cancellableSet)
  }
}

extension DailyTodoViewController: DailyTodoCellDelegate {
  func dailyTodoCell(_ cell: DailyTodoCell, didEditTodo dailyTodo: DailyTodo, done: Bool) {
    if done {
      DailyTodoAPI.doneDailyTodo(dailyTodo: dailyTodo).sink(receiveCompletion: { _ in }, receiveValue: { _ in }).store(in: &cancellableSet)
    } else {
      DailyTodoAPI.undoneDailyTodo(dailyTodo: dailyTodo).sink(receiveCompletion: { _ in }, receiveValue: { _ in }).store(in: &cancellableSet)
    }
  }
}
