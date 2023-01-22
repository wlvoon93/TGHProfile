//
//  UserNoteResponseStorage.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 08/01/2023.
//

import Foundation

protocol UserNoteResponseStorage {
    func getUserNoteResponse(for request: UserNoteRequestDTO, completion: @escaping (Result<Note?, CoreDataStorageError>) -> Void)
    func saveUserNoteResponse(for request: UserNoteRequestDTO, completion: @escaping (VoidResult) -> Void)
}
