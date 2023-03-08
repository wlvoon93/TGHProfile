//
//  UsersPageResponseDTO+Mapping.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 26/12/2022.
//

import Foundation

struct UsersPageResponseDTO: Decodable {
    let since: Int
    let per_page: Int
    let users: [UserDTO]
}

extension UsersPageResponseDTO {
    struct UserDTO: Decodable, Comparable {
                
        let login: String?
        let id: Int
        let profileImage: ProfileImageDTO?
        let imageUrl: String?
        let type: String?
        let note: NoteDTO?
        let following: Int?
        let followers: Int?
        let company: String?
        let blog: String?
        
        static func < (lhs: UsersPageResponseDTO.UserDTO, rhs: UsersPageResponseDTO.UserDTO) -> Bool {
            lhs.id < rhs.id
        }
        
        static func == (lhs: UsersPageResponseDTO.UserDTO, rhs: UsersPageResponseDTO.UserDTO) -> Bool {
            lhs.id == rhs.id
        }

    }
}

extension UsersPageResponseDTO.UserDTO {
    struct NoteDTO: Decodable {
        let note: String?
        let userId: Int
    }
}

extension UsersPageResponseDTO.UserDTO {
    struct ProfileImageDTO: Decodable {
        let image: Data?
        let invertedImage: Data?
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
        
        return .init(login: login,
                     userId: id,
                     profileImage: .init(image: profileImage?.image, invertedImage: profileImage?.invertedImage),
                     imageUrl: imageUrl,
                     type: type,
                     note: nil,
                     following: nil,
                     followers: nil,
                     company: nil,
                     blog: nil)
    }
}

extension UsersPageResponseDTO.UserDTO.ProfileImageDTO {
    func toDomain() -> ProfileImage {
        return .init(image: image,
                     invertedImage: invertedImage)
    }
}
