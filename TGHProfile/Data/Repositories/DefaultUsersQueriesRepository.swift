//
//  DefaultUsersQueriesRepository.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 15.02.19.
//

import Foundation

final class DefaultUsersQueriesRepository {
    
    private let dataTransferService: DataTransferService
    private var usersQueriesPersistentStorage: UsersQueriesStorage
    
    init(dataTransferService: DataTransferService,
         usersQueriesPersistentStorage: UsersQueriesStorage) {
        self.dataTransferService = dataTransferService
        self.usersQueriesPersistentStorage = usersQueriesPersistentStorage
    }
}

extension DefaultUsersQueriesRepository: UsersQueriesRepository {
    
    func fetchRecentsQueries(maxCount: Int, completion: @escaping (Result<[UserQuery], Error>) -> Void) {
        return usersQueriesPersistentStorage.fetchRecentsQueries(maxCount: maxCount, completion: completion)
    }
    
    func saveRecentQuery(query: UserQuery, completion: @escaping (Result<UserQuery, Error>) -> Void) {
        usersQueriesPersistentStorage.saveRecentQuery(query: query, completion: completion)
    }
}
