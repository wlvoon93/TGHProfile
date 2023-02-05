//
//  SearchUserListTableViewController.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 13/01/2023.
//

import UIKit
import SwiftUI

final class SearchUserListTableViewController: UITableViewController {

    var viewModel: UsersListViewModel!

    var profileImagesRepository: ProfileImagesRepository?
    var nextPageLoadingSpinner: UIActivityIndicatorView?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    func reload() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func updateLoading(_ loading: UsersListViewModelLoading?) {
        switch loading {
        case .nextPage:
            nextPageLoadingSpinner?.removeFromSuperview()
            nextPageLoadingSpinner = makeActivityIndicator(size: .init(width: tableView.frame.width, height: 44))
            tableView.tableFooterView = nextPageLoadingSpinner
        case .fullScreen, .none:
            tableView.tableFooterView = nil
        }
    }

    // MARK: - Private

    private func setupViews() {
        tableView.estimatedRowHeight = UsersListItemCell.height
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UsersListItemCell.self, forCellReuseIdentifier: CellTypes.normal.rawValue)
        tableView.register(UserListNoteItemCell.self, forCellReuseIdentifier: CellTypes.note.rawValue)
        tableView.register(UserListAvatarColourInvertedAndNoteItemCell.self, forCellReuseIdentifier: CellTypes.noteAndFourthItem.rawValue)
        tableView.register(UserListAvatarColourInvertedItemCell.self, forCellReuseIdentifier: CellTypes.fourthItem.rawValue)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension SearchUserListTableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.searchItems.value.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.viewModel.searchItems.value[indexPath.row].cellType.rawValue,
                                                       for: indexPath) as? UserListTVCDisplayable else {
            assertionFailure("Cannot dequeue reusable cell \(UsersListItemCell.self) with reuseIdentifier: \(UsersListItemCell.reuseIdentifier)")
            return UITableViewCell()
        }
        if let cellAsTableViewCell = cell as? UITableViewCell {
            cellAsTableViewCell.selectionStyle = UITableViewCell.SelectionStyle.none
        }

        cell.fill(with: viewModel.searchItems.value[indexPath.row],
                  profileImagesRepository: profileImagesRepository)

        if indexPath.row == viewModel.searchItems.value.count - 1 {
            viewModel.didLoadNextPage()
        }

        return cell as? UITableViewCell ?? UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.isSearchEmpty ? tableView.frame.height : super.tableView(tableView, heightForRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectSearchItem(at: indexPath.row)
    }
}
