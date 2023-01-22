//
//  UsersResponseStorage.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 05/04/2020.
//

import Foundation

protocol UsersResponseStorage {
    func getResponse(for request: UsersRequestDTO, completion: @escaping (Result<UsersResponseDTO?, CoreDataStorageError>) -> Void)
    func save(response: UsersResponseDTO, for requestDto: UsersRequestDTO)
}
