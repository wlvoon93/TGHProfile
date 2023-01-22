//
//  User.swift
//  ExampleMVVM
//
//  Created by T0366-ADE-MB-1 on 16/12/2022.
//

import Foundation

struct User: Equatable, Identifiable {
    let login: String?
    let id: Int?
    let avatar_url: String?
    let type: String?
    let note: Note?
}

struct UsersPage: Equatable {
    let since: Int
    let per_page: Int
    let users: [User]
}
