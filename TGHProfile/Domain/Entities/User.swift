//
//  User.swift
//  ExampleMVVM
//
//  Created by T0366-ADE-MB-1 on 16/12/2022.
//

import Foundation

struct User: Equatable, Identifiable {
//    typealias Identifier = String
//    enum Genre {
//        case adventure
//        case scienceFiction
//    }
    // user list and user has different details
    let login: String?
    let id: Int?
    let avatar_url: String?
    let type: String?
}

struct UsersPage: Equatable {
    let since: Int
    let per_page: Int
    let users: [User]
}
