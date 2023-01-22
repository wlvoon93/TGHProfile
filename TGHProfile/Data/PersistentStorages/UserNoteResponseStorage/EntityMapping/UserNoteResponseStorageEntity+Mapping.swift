//
//  UserNoteResponseStorageEntity+Mapping.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 08/01/2023.
//

import Foundation

extension UserNoteEntity {
    func toDomain() -> Note {
        return .init(note: note, userId: Int(userId))
    }
}
