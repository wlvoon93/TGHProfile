//
//  SearchUsersUseCase.swift
//  ExampleMVVM
//
//  Created by T0366-ADE-MB-1 on 16/12/2022.
//

import Foundation

protocol SearchUsersUseCase {
    func execute(requestValue: SearchUsersUseCaseRequestValue,
                 completion: @escaping (Result<UsersPage, Error>) -> Void) -> Cancellable?
}

final class DefaultSearchUsersUseCase: SearchUsersUseCase {
    

    private let usersRepository: UsersRepository

    init(usersRepository: UsersRepository) {

        self.usersRepository = usersRepository
    }

    func execute(requestValue: SearchUsersUseCaseRequestValue, completion: @escaping (Result<UsersPage, Error>) -> Void) -> Cancellable? {

        return usersRepository.searchUsersList(query: requestValue.query,
                                                completion: { result in

            completion(result)
        })
    }
}

struct SearchUsersUseCaseRequestValue {
    let query: String
}
