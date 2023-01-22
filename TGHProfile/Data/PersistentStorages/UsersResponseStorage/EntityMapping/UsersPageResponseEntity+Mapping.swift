//
//  UsersResponseEntity+Mapping.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 05/04/2020.
//

import Foundation
import CoreData

extension UsersPageResponseEntity {
    func toDTO() -> UsersPageResponseDTO {
        return .init(since: Int(since),
                     per_page: Int(perPage),
                     users: users?.allObjects.map{ ($0 as! UserResponseEntity).toDTO() } ?? [])
    }
}

extension UserResponseEntity {
    func toDTO() -> UsersPageResponseDTO.UserDTO {
        return .init(login: login,
                     id: Int(userId),
                     profileImage: profileImage?.toDTO(),
                     type: type,
                     note: nil,
                     following: Int(following),
                     followers: Int(followers),
                     company: company,
                     blog: blog)
    }
}

extension UserProfileImageEntity {
    func toDTO() -> UsersPageResponseDTO.UserDTO.ProfileImageDTO {
        return .init(imageUrl: imageUrl,
                     image: image,
                     invertedImage: invertedImage)
    }
}

extension UsersRequestDTO {
    func toEntity(in context: NSManagedObjectContext) -> UsersRequestEntity {
        let entity: UsersRequestEntity = .init(context: context)
        entity.since = Int32(since)
        entity.perPage = Int32(per_page ?? -1)
        return entity
    }
}

extension UsersPageResponseDTO {
    func toEntity(in context: NSManagedObjectContext) -> UsersPageResponseEntity {
        let entity: UsersPageResponseEntity = .init(context: context)
        entity.since = Int32(since)
        entity.perPage = Int32(per_page)
        users.forEach {
            entity.addToUsers($0.toEntity(in: context))
        }
        return entity
    }
}

extension UsersPageResponseDTO.UserDTO {
    func toEntity(in context: NSManagedObjectContext) -> UserResponseEntity {
        let entity: UserResponseEntity = .init(context: context)
        entity.userId = Int64(id)
        entity.login = login
        entity.profileImage = profileImage?.toEntity(in: context)
        entity.type = type
        return entity
    }
}

extension UsersPageResponseDTO.UserDTO.ProfileImageDTO {
    func toEntity(in context: NSManagedObjectContext) -> UserProfileImageEntity {
        let entity: UserProfileImageEntity = .init(context: context)
        entity.imageUrl = imageUrl
        entity.image = image
        entity.invertedImage = invertedImage
        return entity
    }
}
