//
//  SaveUserNoteResponseDTO+mapping.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 08/01/2023.
//

import Foundation

struct SaveUserNoteResponseDTO: Decodable {
    let note: String?
    let userId: Int?
}
