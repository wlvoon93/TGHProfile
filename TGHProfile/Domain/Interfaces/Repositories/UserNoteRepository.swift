//
//  UserNoteRepository.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 08/01/2023.
//

import Foundation

protocol UserNoteRepository {
    @discardableResult
    func getUserNoteResponse(userId: Int,
                         completion: @escaping (Result<Note, Error>) -> Void) -> Cancellable?
    @discardableResult
    func saveUserNoteResponse(userId: Int, note: String, completion: @escaping (VoidResult) -> Void) -> Cancellable?
}
