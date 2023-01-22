//
//  UsersListItemViewModel.swift
//  ExampleMVVM
//
//  Created by T0366-ADE-MB-1 on 15/12/2022.
//

import Foundation

struct UsersListItemViewModel: Equatable {
    let username: String
    let type: String
    let profileImagePath: String?
}

extension UsersListItemViewModel {

    init(user: User) {
        self.username = user.login ?? ""
        self.profileImagePath = user.avatar_url
        self.type = user.type ?? ""
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()
