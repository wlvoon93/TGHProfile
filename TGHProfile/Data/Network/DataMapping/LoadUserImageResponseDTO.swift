//
//  LoadUserImageResponseDTO.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 08/03/2023.
//

import Foundation

struct LoadUserImageResponseDTO: Encodable {
    let image: Data?
    let imageUrl: String?
    let invertedImage: Int?
    let userId: Int
}
