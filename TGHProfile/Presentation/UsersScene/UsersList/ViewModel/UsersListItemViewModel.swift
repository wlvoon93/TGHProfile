//
//  UsersListItemViewModel.swift
//  ExampleMVVM
//
//  Created by T0366-ADE-MB-1 on 15/12/2022.
//

import Foundation

struct UsersListItemViewModel: Equatable, BaseItemViewModel {
    let cellType: CellTypes
    let user: User
}

extension UsersListItemViewModel {

    init(user: User) {
        self.user = user
        self.cellType = .normal
    }
}
