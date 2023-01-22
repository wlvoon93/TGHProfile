//
//  UsersResponseEntity+Mapping.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 05/04/2020.
//

import Foundation
import CoreData

extension UsersResponseEntity {
    func toDTO() -> UsersResponseDTO {
        return .init(page: Int(page),
                     totalPages: Int(totalPages),
                     users: users?.allObjects.map { ($0 as! UserResponseEntity).toDTO() } ?? [])
    }
}

extension UserResponseEntity {
    func toDTO() -> UsersResponseDTO.UserDTO {
        return .init(id: Int(id),
                     title: title,
                     genre: UsersResponseDTO.UserDTO.GenreDTO(rawValue: genre ?? ""),
                     posterPath: posterPath,
                     overview: overview,
                     releaseDate: releaseDate)
    }
}

extension UsersRequestDTO {
    func toEntity(in context: NSManagedObjectContext) -> UsersRequestEntity {
        let entity: UsersRequestEntity = .init(context: context)
        entity.query = query
        entity.page = Int32(page)
        return entity
    }
}

extension UsersResponseDTO {
    func toEntity(in context: NSManagedObjectContext) -> UsersResponseEntity {
        let entity: UsersResponseEntity = .init(context: context)
        entity.page = Int32(page)
        entity.totalPages = Int32(totalPages)
        users.forEach {
            entity.addToUsers($0.toEntity(in: context))
        }
        return entity
    }
}

extension UsersResponseDTO.UserDTO {
    func toEntity(in context: NSManagedObjectContext) -> UserResponseEntity {
        let entity: UserResponseEntity = .init(context: context)
        entity.id = Int64(id)
        entity.title = title
        entity.genre = genre?.rawValue
        entity.posterPath = posterPath
        entity.overview = overview
        entity.releaseDate = releaseDate
        return entity
    }
}
