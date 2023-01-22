//
//  UsersListItemViewModel.swift
//  ExampleMVVM
//
//  Created by T0366-ADE-MB-1 on 15/12/2022.
//

import Foundation

struct UsersListItemViewModel: Equatable {
    let title: String
    let overview: String
    let releaseDate: String
    let posterImagePath: String?
}

extension UsersListItemViewModel {

    init(user: User) {
        self.title = user.login ?? ""
        self.posterImagePath = user.login
        self.overview = user.login ?? ""
        self.releaseDate = title
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()
