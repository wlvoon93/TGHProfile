//
//  MoviesRepositoryInterfaces.swift
//  ExampleMVVM
//
//  Created by T0366-ADE-MB-1 on 16/12/2022.
//

import Foundation

protocol UsersRepository {
    @discardableResult
    func fetchUsersList(query: UserQuery, page: Int,
                         cached: @escaping (UsersPage) -> Void,
                         completion: @escaping (Result<UsersPage, Error>) -> Void) -> Cancellable?
}
