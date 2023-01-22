//
//  UsersSearchFlowCoordinator.swift
//  ExampleMVVM
//
//  Created by T0366-ADE-MB-1 on 15/12/2022.
//

import UIKit

protocol UsersSearchFlowCoordinatorDependencies  {
    func makeUsersListViewController(actions: UsersListViewModelActions) -> UsersListViewController
    func makeUsersDetailsViewController(username: String, note: String, didSaveNote: @escaping (Note) -> Void) -> UIViewController
}

final class UsersSearchFlowCoordinator {
    
    private weak var navigationController: UINavigationController?
    private let dependencies: UsersSearchFlowCoordinatorDependencies

    private weak var usersListVC: UsersListViewController?
    private weak var usersQueriesSuggestionsVC: UIViewController?

    init(navigationController: UINavigationController,
         dependencies: UsersSearchFlowCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func start() {
        // Note: here we keep strong reference with actions, this way this flow do not need to be strong referenced
        let actions = UsersListViewModelActions(showUserDetails: showUserDetails)
        let vc = dependencies.makeUsersListViewController(actions: actions)

        navigationController?.pushViewController(vc, animated: false)
        usersListVC = vc
    }

    private func showUserDetails(username: String, note: String, didSaveNote: @escaping (Note) -> Void) {
        let vc = dependencies.makeUsersDetailsViewController(username: username, note: note, didSaveNote: didSaveNote)
        vc.title = username
        navigationController?.pushViewController(vc, animated: true)
    }

    private func closeUserQueriesSuggestions() {
        usersQueriesSuggestionsVC?.remove()
        usersQueriesSuggestionsVC = nil
        usersListVC?.rootView.suggestionsListContainerView.isHidden = true
    }
}
