//
//  UsersQueriesStorage.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 16.08.19.
//

import Foundation

protocol UsersQueriesStorage {
    func fetchRecentsQueries(maxCount: Int, completion: @escaping (Result<[UserQuery], Error>) -> Void)
    func saveRecentQuery(query: UserQuery, completion: @escaping (Result<UserQuery, Error>) -> Void)
}
