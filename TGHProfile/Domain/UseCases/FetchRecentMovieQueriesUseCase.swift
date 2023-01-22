//
//  FetchRecentUserQueriesUseCase.swift
//  ExampleMVVM
//
//  Created by T0366-ADE-MB-1 on 16/12/2022.
//

import Foundation

// This is another option to create Use Case using more generic way
final class FetchRecentUserQueriesUseCase: UseCase {

    struct RequestValue {
        let maxCount: Int
    }
    typealias ResultValue = (Result<[UserQuery], Error>)

    private let requestValue: RequestValue
    private let completion: (ResultValue) -> Void
    private let usersQueriesRepository: UsersQueriesRepository

    init(requestValue: RequestValue,
         completion: @escaping (ResultValue) -> Void,
         usersQueriesRepository: UsersQueriesRepository) {

        self.requestValue = requestValue
        self.completion = completion
        self.usersQueriesRepository = usersQueriesRepository
    }
    
    func start() -> Cancellable? {

        usersQueriesRepository.fetchRecentsQueries(maxCount: requestValue.maxCount, completion: completion)
        return nil
    }
}
