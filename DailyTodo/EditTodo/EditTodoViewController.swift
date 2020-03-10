//
//  EditTodoViewController.swift
//  DailyTodo
//
//  Created by ishida on 2020/02/27.
//  Copyright © 2020 ishida. All rights reserved.
//

import Combine
import DailyTodoSDK
import MobileCoreServices
import UIKit

class EditTodoViewController: UIViewController {
  enum Section: Int {
    case main = 0
    case new
  }

  @IBOutlet weak var tableView: UITableView!
  private var dataSource: UITableViewDiffableDataSource<Section, Todo>!
  private var cancellableSet: Set<AnyCancellable> = []

  override func viewDidLoad() {
    super.viewDidLoad()

    configureTableView()
    configureDataSource()
    watchTodoList()
  }
}

// MARK: - Private Functions
extension EditTodoViewController {
  private func configureTableView() {
    tableView.delegate = self
    tableView.dragDelegate = self
    tableView.dragInteractionEnabled = true

    NotificationCenter.default
      .publisher(for: UIResponder.keyboardWillShowNotification)
      .map { notification -> (frame: CGRect?, duration: Double) in
        let frame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        return (frame: frame, duration: duration ?? 0)
      }
      .sink {
        guard let keyboardHeight = $0.frame?.height else { return }

        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
      }.store(in: &cancellableSet)

    NotificationCenter.default
      .publisher(for: UIResponder.keyboardWillHideNotification)
      .sink { _ in
        self.tableView.contentInset = .zero
      }.store(in: &cancellableSet)
  }

  private func configureDataSource() {
    dataSource = DataSource(tableView: tableView) { (tableView, indexPath, todo) in
      guard let cell = tableView.dequeueReusableCell(withIdentifier: EditableTodoCell.identifier, for: indexPath) as? EditableTodoCell else {
        fatalError("Cannot create new cell")
      }

      cell.delegate = self
      cell.todo = todo
      cell.isNew = Section(rawValue: indexPath.section) == .new

      return cell
    }
    dataSource.defaultRowAnimation = .fade
  }

  private func watchTodoList() {
    DailyTodoAPI.watchTodoList()
      .map {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Todo>()
        snapshot.appendSections([.main, .new])
        snapshot.appendItems($0, toSection: .main)
        snapshot.appendItems([Todo.empty], toSection: .new)
        snapshot.reloadSections([.new])
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

// MARK: - EditableTodoCellDelegate
extension EditTodoViewController: EditableTodoCellDelegate {
  func editableTodoCell(_ cell: EditableTodoCell, didEditTodo todo: Todo, newTitle: String) {
    guard todo.title != newTitle else { return }

    if cell.isNew {
      addTodo(withTitle: newTitle)
    } else {
      updateTodo(todo.updated(withTitle: newTitle))
    }
  }

  private func addTodo(withTitle title: String) {
    DailyTodoAPI.nextOrder()
      .map { Todo(title: title, order: $0) }
      .map { DailyTodoAPI.addTodo(todo: $0) }
      .sink(
        receiveCompletion: { _ in },
        receiveValue: { _ in }
      ).store(in: &cancellableSet)
  }

  private func updateTodo(_ todo: Todo) {
    DailyTodoAPI.updateTodo(withId: todo.id, title: todo.title).sink(
      receiveCompletion: { _ in },
      receiveValue: { _ in }
    ).store(in: &cancellableSet)
  }
}

// MARK: - UITableViewDiffableDataSource
extension EditTodoViewController {
  class DataSource: UITableViewDiffableDataSource<Section, Todo> {
    private var cancellableSet: Set<AnyCancellable> = []

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
      return Section(rawValue: indexPath.section) == .main
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
      return Section(rawValue: indexPath.section) == .main
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
      if sourceIndexPath == destinationIndexPath { return }

      DailyTodoAPI.updateReorderedTodoList(todoList: self.snapshot().itemIdentifiers(inSection: .main), from: sourceIndexPath.row, to: destinationIndexPath.row).sink(
        receiveCompletion: { _ in },
        receiveValue: { _ in }
      ).store(in: &cancellableSet)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {
        if let identifierToDelete = itemIdentifier(for: indexPath) {
          DailyTodoAPI.deleteTodo(identifierToDelete).sink(
            receiveCompletion: { _ in },
            receiveValue: { _ in }
          ).store(in: &cancellableSet)
        }
      }
    }
  }
}

// MARK: - UITableViewDelegate
extension EditTodoViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
    if Section(rawValue: proposedDestinationIndexPath.section) == .main {
      return proposedDestinationIndexPath
    } else {
      return sourceIndexPath
    }
  }
}

// MARK: - UITableViewDragDelegate
extension EditTodoViewController: UITableViewDragDelegate {
  func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
    []
  }
}

extension EditTodoViewController: UITableViewDropDelegate {
  func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
  }

  func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
    if tableView.hasActiveDrag {
      if session.items.count > 1 {
        return UITableViewDropProposal(operation: .cancel)
      } else {
        return UITableViewDropProposal(operation: .move, intent: .automatic)
      }
    } else {
      return UITableViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
    }
  }
}
