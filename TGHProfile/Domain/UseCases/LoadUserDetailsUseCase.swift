//
//  LoadUserDetailsUseCase.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 29/12/2022.
//

import Foundation

protocol LoadUserDetailsUseCase {
    func execute(requestValue: LoadUserDetailsUseCaseRequestValue,
                 cached: @escaping (User) -> Void,
                 completion: @escaping (Result<User, Error>) -> Void) -> Cancellable? 
}

final class DefaultLoadUserDetailsUseCase: LoadUserDetailsUseCase {

    private let usersRepository: UsersRepository

    init(usersRepository: UsersRepository) {

        self.usersRepository = usersRepository
    }

    func execute(requestValue: LoadUserDetailsUseCaseRequestValue,
                 cached: @escaping (User) -> Void,
                 completion: @escaping (Result<User, Error>) -> Void) -> Cancellable? {

        return usersRepository.fetchUserDetails(query: .init(username: requestValue.username),
                                                cached: cached,
                                                completion: { result in
            completion(result)
        })
    }
}

struct LoadUserDetailsUseCaseRequestValue {
    let username: String
}
