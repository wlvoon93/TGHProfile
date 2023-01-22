//
//  UserListNoteItemViewModel.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 09/01/2023.
//

import Foundation

struct UserListNoteItemViewModel: Equatable, BaseItemViewModel {
    let cellType: CellTypes
    let user: User
}

extension UserListNoteItemViewModel {

    init(user: User) {
        self.user = user
        self.cellType = .note
    }
}
