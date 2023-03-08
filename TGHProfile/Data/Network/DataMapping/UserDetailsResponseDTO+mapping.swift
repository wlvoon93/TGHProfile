//
//  UserDetailsResponseDTO+mapping.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 04/01/2023.
//

import Foundation
import SwiftUI

// MARK: - Data Transfer Object

struct UserDetailsResponseDTO: Decodable {
    let login: String?
    let id: Int?
    let avatar_url: String?
    let type: String?
    let following: Int?
    let followers: Int?
    let company: String?
    let blog: String?
}

// MARK: - Mappings to Domain

extension UserDetailsResponseDTO {
    func toDomain() -> User {
        return .init(login: login,
                     userId: id,
                     profileImage: .init(image: nil, invertedImage: nil),
                     imageUrl: avatar_url,
                     type: type,
                     note: nil,
                     following: following,
                     followers: followers,
                     company: company,
                     blog: blog)
    }
}
