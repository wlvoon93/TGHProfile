//
//  BaseItemCell.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 09/01/2023.
//

import UIKit

protocol BaseItemCell {
    var viewModel: BaseItemViewModel? { get }
    
    func fill(with viewModel: BaseItemViewModel, profileImagesRepository: ProfileImagesRepository?)
}
