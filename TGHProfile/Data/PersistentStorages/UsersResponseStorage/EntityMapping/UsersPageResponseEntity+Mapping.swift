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
                     per_page: Int(per_page),
                     users: users?.allObjects.map{ ($0 as! UserResponseEntity).toDTO() } ?? [])
    }
}

extension UserResponseEntity {
    func toDTO() -> UsersPageResponseDTO.UserDTO {
        return .init(login: login,
                     id: Int(id),
                     avatar_url: avatar_url)
    }
}

extension UsersRequestDTO {
    func toEntity(in context: NSManagedObjectContext) -> UsersRequestEntity {
        let entity: UsersRequestEntity = .init(context: context)
        entity.since = Int32(since)
        entity.per_page = Int32(per_page)
        return entity
    }
}

extension UsersPageResponseDTO {
    func toEntity(in context: NSManagedObjectContext) -> UsersPageResponseEntity {
        let entity: UsersPageResponseEntity = .init(context: context)
        entity.since = Int32(since)
        entity.per_page = Int32(per_page)
        return entity
    }
}
//
//extension UsersResponseDTO.UserDTO {
//    func toEntity(in context: NSManagedObjectContext) -> UserResponseEntity {
//        let entity: UserResponseEntity = .init(context: context)
//        entity.id = Int64(id)
//        entity.title = title
//        entity.genre = genre?.rawValue
//        entity.posterPath = posterPath
//        entity.overview = overview
//        entity.releaseDate = releaseDate
//        return entity
//    }
//}
