//
//  UsersPageResponseDTO+Mapping.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 26/12/2022.
//

import Foundation

//struct UsersPageResponseDTO: Decodable {
//    let since: Int?
//    let per_page: Int?
//    let users: [User]?
//}

struct UsersPageResponseDTO: Decodable {
    let since: Int
    let per_page: Int
    let users: [UserDTO]
}

extension UsersPageResponseDTO {
    struct UserDTO: Decodable {
        let login: String?
        let id: Int?
        let avatar_url: String?
    }
}

extension UsersPageResponseDTO {
    func toDomain() -> UsersPage {
        return .init(since: since,
                     per_page: per_page,
                     users: users.map { $0.toDomain() })
    }
}

extension UsersPageResponseDTO.UserDTO {
    func toDomain() -> User {
        return .init(login: login, id: id, avatar_url: avatar_url)
    }
}
