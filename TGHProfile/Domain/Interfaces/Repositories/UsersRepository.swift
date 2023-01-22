//
//  MoviesRepositoryInterfaces.swift
//  ExampleMVVM
//
//  Created by T0366-ADE-MB-1 on 16/12/2022.
//

import Foundation

protocol UsersRepository {
    @discardableResult
    func fetchAllUsersList(since: Int,
                           per_page: Int?,                           cached: @escaping (UsersPage) -> Void,
                           completion: @escaping (Result<UsersPage, Error>) -> Void) -> Cancellable?
    @discardableResult
    func searchUsersList(query: String,
                         completion: @escaping (Result<UsersPage, Error>) -> Void) -> Cancellable?
    
    @discardableResult
    func fetchUserDetails(query: UserDetailsQuery,
                          cached: @escaping (User) -> Void,
                          completion: @escaping (Result<User, Error>) -> Void) -> Cancellable?
}
