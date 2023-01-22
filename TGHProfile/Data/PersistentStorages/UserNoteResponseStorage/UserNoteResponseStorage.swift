//
//  UserNoteResponseStorage.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 08/01/2023.
//

import Foundation

protocol UserNoteResponseStorage {
    func loadUserNoteResponse(for request: LoadUserNoteRequestDTO, completion: @escaping (Result<Note?, CoreDataStorageError>) -> Void)
    func loadUsersNoteResponse(for users: [Int], completion: @escaping (Result<[Note], CoreDataStorageError>) -> Void)
    func saveUserNoteResponse(for request: SaveUserNoteRequestDTO, completion: @escaping (VoidResult) -> Void)
}
