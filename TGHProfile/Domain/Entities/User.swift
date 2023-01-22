//
//  User.swift
//  ExampleMVVM
//
//  Created by T0366-ADE-MB-1 on 16/12/2022.
//

import Foundation
import SwiftUI

struct User: Equatable {
    let login: String?
    let userId: Int?
    let profileImage: ProfileImage?
    let type: String?
    let note: Note?
    let following: Int?
    let followers: Int?
    let company: String?
    let blog: String?
}

struct UsersPage: Equatable {
    let since: Int
    let per_page: Int
    let users: [User]
}
