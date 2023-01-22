//
//  BaseItemViewModel.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 09/01/2023.
//

import Foundation
import UIKit

//class BaseItemViewModel{
//    var cellType: CellTypes
//
//    init(cellType: CellTypes) {
//        self.cellType = cellType
//    }
//}

enum CellTypes: String{
    case normal = "normalCell"
    case fourthItem = "fourthItemCell"
    case note = "noteCell"
    case noteAndFourthItem = "noteAndFourthItemCell"
}

protocol BaseItemViewModel {
    var user: User { get }
    var cellType: CellTypes { get }
}
