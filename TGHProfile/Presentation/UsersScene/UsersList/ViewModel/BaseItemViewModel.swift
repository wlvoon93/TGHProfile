//
//  BaseItemViewModel.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 09/01/2023.
//

import Foundation
import UIKit

enum CellTypes: String{
    case normal = "normalCell"
    case fourthItem = "fourthItemCell"
    case note = "noteCell"
    case noteAndFourthItem = "noteAndFourthItemCell"
}

protocol UserListTVCVMDisplayable {
    var user: User { get set }
    var cellType: CellTypes { get }
}
