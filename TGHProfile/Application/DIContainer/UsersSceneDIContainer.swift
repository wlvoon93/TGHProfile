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
    func makePosterImagesRepository() -> PosterImagesRepository {
        return DefaultPosterImagesRepository(dataTransferService: dependencies.imageDataTransferService)
    }
    
    // MARK: - Users List
    func makeUsersListViewController(actions: UsersListViewModelActions) -> UsersListViewController {
        return UsersListViewController.create(with: makeUsersListViewModel(actions: actions),
                                               posterImagesRepository: makePosterImagesRepository())
    }
    
    func makeUsersListViewModel(actions: UsersListViewModelActions) -> UsersListViewModel {
        return DefaultUsersListViewModel(searchUsersUseCase: makeSearchUsersUseCase(), listAllUsersUseCase: makeListAllUsersUseCase(), actions: actions)
    }
    
    // MARK: - User Details
    func makeUsersDetailsViewController(user: User) -> UIViewController {
        return UserDetailsViewController.create(with: makeUsersDetailsViewModel(user: user))
    }
    
    func makeUsersDetailsViewModel(user: User) -> UserDetailsViewModel {
        return DefaultUserDetailsViewModel(user: user,
                                            posterImagesRepository: makePosterImagesRepository())
    }

    // MARK: - Flow Coordinators
    func makeUsersSearchFlowCoordinator(navigationController: UINavigationController) -> UsersSearchFlowCoordinator {
        return UsersSearchFlowCoordinator(navigationController: navigationController,
                                           dependencies: self)
    }
}

extension UsersSceneDIContainer: UsersSearchFlowCoordinatorDependencies {}
