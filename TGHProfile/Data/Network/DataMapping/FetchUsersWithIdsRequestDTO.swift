//
//  FetchUsersWithIdsRequestDTO.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 17/01/2023.
//

import Foundation

struct FetchUsersWithIdsRequestDTO: Encodable {
    let ids: [Int]
}
