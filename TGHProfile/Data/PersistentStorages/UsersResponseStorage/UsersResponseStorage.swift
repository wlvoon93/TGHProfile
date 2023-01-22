//
//  UsersResponseStorage.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 05/04/2020.
//

import Foundation

protocol UsersResponseStorage {
    func getResponse(for request: UsersRequestDTO, completion: @escaping (Result<UsersPageResponseDTO?, CoreDataStorageError>) -> Void)
    func save(response: UsersPageResponseDTO, for requestDto: UsersRequestDTO)
}
