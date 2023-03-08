//
//  UserListAvatarColourInvertedItemViewModel.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 09/01/2023.
//

import Foundation
import UIKit

class UserListAvatarColourInvertedItemViewModel: UserListTVCVMDisplayable {
    var cacheImage: UIImage?
    
    let cellType: CellTypes = .fourthItem
    var user: User
    
    init(user: User) {
        self.user = user
    }
}
