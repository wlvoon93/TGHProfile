//
//  BaseItemCell.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 09/01/2023.
//

import UIKit

protocol UserListTVCDisplayable {
    var viewModel: UserListTVCVMDisplayable? { get }
    
    func fill(with viewModel: UserListTVCVMDisplayable, profileImagesRepository: ProfileImagesRepository?)
}
