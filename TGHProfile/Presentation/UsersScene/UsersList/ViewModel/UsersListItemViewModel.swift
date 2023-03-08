//
//  UsersListItemViewModel.swift
//  ExampleMVVM
//
//  Created by T0366-ADE-MB-1 on 15/12/2022.
//

import Foundation
import UIKit

class UsersListItemViewModel: UserListTVCVMDisplayable {
    
    var cacheImage: UIImage?
    
    let cellType: CellTypes = .normal
    var user: User
    
    init(user: User) {
        self.user = user
    }
}
