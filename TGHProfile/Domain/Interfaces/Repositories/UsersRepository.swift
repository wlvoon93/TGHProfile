//
//  MoviesRepositoryInterfaces.swift
//  ExampleMVVM
//
//  Created by T0366-ADE-MB-1 on 16/12/2022.
//

import Foundation

protocol UsersRepository {
    @discardableResult
    func fetchAllUsersList(page: Int,
                         cached: @escaping (UsersPage) -> Void,
                         completion: @escaping (Result<UsersPage, Error>) -> Void) -> Cancellable?
    @discardableResult
    func searchUsersList(query: UserQuery, page: Int,
                         cached: @escaping (UsersPage) -> Void,
                         completion: @escaping (Result<UsersPage, Error>) -> Void) -> Cancellable?
    
    @discardableResult
    func fetchUserDetails(query: UserDetailsQuery,
                          completion: @escaping (Result<User, Error>) -> Void) -> Cancellable?
}
