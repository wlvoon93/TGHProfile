//
//  UsersSceneDIContainer.swift
//  ExampleMVVM
//
//  Created by T0366-ADE-MB-1 on 15/12/2022.
//

import UIKit
import SwiftUI

final class UsersSceneDIContainer {
    
    struct Dependencies {
        let apiDataTransferService: DataTransferService
        let imageDataTransferService: DataTransferService
    }
    
    private let dependencies: Dependencies

    // MARK: - Persistent Storage
    lazy var usersQueriesStorage: UsersQueriesStorage = CoreDataUsersQueriesStorage(maxStorageLimit: 10)
    lazy var usersResponseCache: UsersResponseStorage = CoreDataUsersResponseStorage()

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Use Cases
    func makeSearchUsersUseCase() -> SearchUsersUseCase {
        return DefaultSearchUsersUseCase(usersRepository: makeUsersRepository(),
                                          usersQueriesRepository: makeUsersQueriesRepository())
    }
    
    func makeListAllUsersUseCase() -> ListAllUsersUseCase {
        return DefaultListAllUsersUseCase(usersRepository: makeUsersRepository(),
                                          usersQueriesRepository: makeUsersQueriesRepository())
    }
    
    func makeLoadUserDetailsUseCase() -> LoadUserDetailsUseCase {
        return DefaultLoadUserDetailsUseCase(usersRepository: makeUsersRepository(), usersQueriesRepository: makeUserDetailsQueriesRepository())
    }
    
    func makeFetchRecentUserQueriesUseCase(requestValue: FetchRecentUserQueriesUseCase.RequestValue,
                                            completion: @escaping (FetchRecentUserQueriesUseCase.ResultValue) -> Void) -> UseCase {
        return FetchRecentUserQueriesUseCase(requestValue: requestValue,
                                              completion: completion,
                                              usersQueriesRepository: makeUsersQueriesRepository()
        )
    }
    
    // MARK: - Repositories
    func makeUsersRepository() -> UsersRepository {
        return DefaultUsersRepository(dataTransferService: dependencies.apiDataTransferService, cache: usersResponseCache)
    }
    func makeUsersQueriesRepository() -> UsersQueriesRepository {
        return DefaultUsersQueriesRepository(dataTransferService: dependencies.apiDataTransferService,
                                              usersQueriesPersistentStorage: usersQueriesStorage)
    }
    func makeUserDetailsQueriesRepository() -> UsersQueriesRepository {
        return DefaultUsersQueriesRepository(dataTransferService: dependencies.apiDataTransferService,
                                              usersQueriesPersistentStorage: usersQueriesStorage)
    }
    func makeProfileImagesRepository() -> ProfileImagesRepository {
        return DefaultProfileImagesRepository(dataTransferService: dependencies.imageDataTransferService)
    }
    
    // MARK: - Users List
    func makeUsersListViewController(actions: UsersListViewModelActions) -> UsersListViewController {
        return UsersListViewController.create(with: makeUsersListViewModel(actions: actions),
                                              profileImagesRepository: makeProfileImagesRepository())
    }
    
    func makeUsersListViewModel(actions: UsersListViewModelActions) -> UsersListViewModel {
        return DefaultUsersListViewModel(searchUsersUseCase: makeSearchUsersUseCase(), listAllUsersUseCase: makeListAllUsersUseCase(), actions: actions)
    }
    
    // MARK: - User Details
    func makeUsersDetailsViewController(username: String) -> UIViewController {
        let view = UserDetailsView(viewModelWrapper: makeUserDetailsViewModelWrapper(username: username))
        return UIHostingController(rootView: view)
    }
    
    func makeUserDetailsViewModel(username: String) -> UserDetailsViewModel {
        return DefaultUserDetailsViewModel(username: username, loadUserDetailsUseCase: makeLoadUserDetailsUseCase())
    }
    
    func makeUserDetailsViewModelWrapper(username: String) -> UserDetailsViewModelWrapper {
        return UserDetailsViewModelWrapper(viewModel: makeUserDetailsViewModel(username: username))
    }

    // MARK: - Flow Coordinators
    func makeUsersSearchFlowCoordinator(navigationController: UINavigationController) -> UsersSearchFlowCoordinator {
        return UsersSearchFlowCoordinator(navigationController: navigationController,
                                           dependencies: self)
    }
}

extension UsersSceneDIContainer: UsersSearchFlowCoordinatorDependencies {}
