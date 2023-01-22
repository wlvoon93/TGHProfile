//
//  UserNoteRequestDTO+mapping.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 08/01/2023.
//

import Foundation

struct UserNoteRequestDTO: Encodable {
    let userId: Int
    let note: String
}
