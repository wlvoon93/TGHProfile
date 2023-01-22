//
//  MoviesQueriesRepositoryInterface.swift
//  ExampleMVVM
//
//  Created by T0366-ADE-MB-1 on 16/12/2022.
//

import Foundation

protocol UsersQueriesRepository {
    func fetchRecentsQueries(maxCount: Int, completion: @escaping (Result<[UserQuery], Error>) -> Void)
    func saveRecentQuery(query: UserQuery, completion: @escaping (Result<UserQuery, Error>) -> Void)
}
