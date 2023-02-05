//
//  UserListNoteItemViewModel.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 09/01/2023.
//

import Foundation
import UIKit

struct UserListNoteItemViewModel: Equatable, UserListTVCVMDisplayable {
    var cacheImage: UIImage?
    
    let cellType: CellTypes
    var user: User
}

extension UserListNoteItemViewModel {

    init(user: User) {
        self.user = user
        self.cellType = .note
    }
}
