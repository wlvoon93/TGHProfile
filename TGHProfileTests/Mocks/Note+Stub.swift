//
//  Note+Stub.swift
//  TGHProfileTests
//
//  Created by T0366-ADE-MB-1 on 11/01/2023.
//

import Foundation
@testable import TGHProfile

extension Note {
    static func stub(note: String = "",
                        userId: Int = -1) -> Self {
        Note(note: note, userId: userId)
    }
}
