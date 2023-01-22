//
//  UsersResponseDTO+Mapping.swift
//  Data
//
//  Created by Oleh Kudinov on 12.08.19.
//  Copyright © 2019 Oleh Kudinov. All rights reserved.
//

import Foundation

// MARK: - Data Transfer Object

struct UsersResponseDTO: Decodable {
    private enum CodingKeys: String, CodingKey {
        case page
        case totalPages = "total_pages"
        case users = "results"
    }
    let page: Int
    let totalPages: Int
    let users: [UserDTO]
}

extension UsersResponseDTO {
    struct UserDTO: Decodable {
        private enum CodingKeys: String, CodingKey {
            case id
            case title
            case genre
            case posterPath = "poster_path"
            case overview
            case releaseDate = "release_date"
        }
        enum GenreDTO: String, Decodable {
            case adventure
            case scienceFiction = "science_fiction"
        }
        let id: Int
        let title: String?
        let genre: GenreDTO?
        let posterPath: String?
        let overview: String?
        let releaseDate: String?
    }
}

// MARK: - Mappings to Domain

extension UsersResponseDTO {
    func toDomain() -> UsersPage {
        return .init(page: page,
                     totalPages: totalPages,
                     users: users.map { $0.toDomain() })
    }
}

extension UsersResponseDTO.UserDTO {
    func toDomain() -> User {
        return .init(id: User.Identifier(id),
                     title: title,
                     genre: genre?.toDomain(),
                     posterPath: posterPath,
                     overview: overview,
                     releaseDate: dateFormatter.date(from: releaseDate ?? ""))
    }
}

extension UsersResponseDTO.UserDTO.GenreDTO {
    func toDomain() -> User.Genre {
        switch self {
        case .adventure: return .adventure
        case .scienceFiction: return .scienceFiction
        }
    }
}

// MARK: - Private

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
}()
