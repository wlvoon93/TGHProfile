//
//  SearchUsersUseCase.swift
//  ExampleMVVM
//
//  Created by T0366-ADE-MB-1 on 16/12/2022.
//

import Foundation

protocol SearchUsersUseCase {
    func execute(requestValue: SearchUsersUseCaseRequestValue,
                 cached: @escaping (UsersPage) -> Void,
                 completion: @escaping (Result<UsersPage, Error>) -> Void) -> Cancellable?
}

final class DefaultSearchUsersUseCase: SearchUsersUseCase {

    private let usersRepository: UsersRepository
    private let usersQueriesRepository: UsersQueriesRepository

    init(usersRepository: UsersRepository,
         usersQueriesRepository: UsersQueriesRepository) {

        self.usersRepository = usersRepository
        self.usersQueriesRepository = usersQueriesRepository
    }

    func execute(requestValue: SearchUsersUseCaseRequestValue,
                 cached: @escaping (UsersPage) -> Void,
                 completion: @escaping (Result<UsersPage, Error>) -> Void) -> Cancellable? {

        return usersRepository.fetchUsersList(query: requestValue.query,
                                                page: requestValue.page,
                                                cached: cached,
                                                completion: { result in

            if case .success = result {
                self.usersQueriesRepository.saveRecentQuery(query: requestValue.query) { _ in }
            }

            completion(result)
        })
    }
}

struct SearchUsersUseCaseRequestValue {
    let query: UserQuery
    let page: Int
}
