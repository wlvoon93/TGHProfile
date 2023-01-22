//
//  UsersResponseStorage.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 05/04/2020.
//

import Foundation

protocol UsersResponseStorage {
    func getResponse(for request: UsersRequestDTO, completion: @escaping (Result<UsersPageResponseDTO?, CoreDataStorageError>) -> Void)
    func getUserDetailsResponse(for request: UserDetailsRequestDTO, completion: @escaping (Result<UsersPageResponseDTO.UserDTO?, CoreDataStorageError>) -> Void)
    func searchUsersWithUsernameAndNoteKeyword(for requestDto: LoadUsersWithUsernameAndNoteKeywordRequestDTO, completion: @escaping (Result<UsersPageResponseDTO?, CoreDataStorageError>) -> Void)
    func save(response: UsersPageResponseDTO, for requestDto: UsersRequestDTO)
    func updateUser(response responseDto: UserDetailsResponseDTO, for requestDto: UserDetailsRequestDTO)
}
