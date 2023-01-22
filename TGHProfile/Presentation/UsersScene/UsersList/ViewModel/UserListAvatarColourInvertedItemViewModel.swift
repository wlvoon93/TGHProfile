//
//  UserListAvatarColourInvertedItemViewModel.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 09/01/2023.
//

import Foundation
import UIKit

struct UserListAvatarColourInvertedItemViewModel: Equatable, BaseItemViewModel {
    var profileImage: UIImage?
    let cellType: CellTypes
    let user: User
}

extension UserListAvatarColourInvertedItemViewModel {

    init(user: User) {
        self.user = user
        self.cellType = .fourthItem
    }
}
