//
//  ListAllUsersUseCase.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 25/12/2022.
//

import Foundation

protocol ListAllUsersUseCase {
    func execute(requestValue: ListAllUsersUseCaseRequestValue,
                 cached: @escaping (UsersPage) -> Void,
                 completion: @escaping (Result<UsersPage, Error>) -> Void) -> Cancellable?
}

final class DefaultListAllUsersUseCase: ListAllUsersUseCase {

    private let usersRepository: UsersRepository

    init(usersRepository: UsersRepository) {

        self.usersRepository = usersRepository
    }

    func execute(requestValue: ListAllUsersUseCaseRequestValue,
                 cached: @escaping (UsersPage) -> Void,
                 completion: @escaping (Result<UsersPage, Error>) -> Void) -> Cancellable? {

        return usersRepository.fetchAllUsersList(page: requestValue.page,
                                                cached: cached,
                                                completion: { result in
            
            completion(result)
        })
    }
}

struct ListAllUsersUseCaseRequestValue {
    let page: Int
}
