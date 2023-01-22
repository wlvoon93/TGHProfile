//
//  UsersSearchResponseDTO+Mapping.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 24/12/2022.
//

import Foundation

// MARK: - Data Transfer Object

struct UsersSearchResponseDTO: Decodable {
    let login: String?
    let id: Int?
    let avatar_url: String?
}

// MARK: - Mappings to Domain

extension UsersSearchResponseDTO {
    func toDomain() -> User {
        return .init(login: login, id: id, avatar_url: avatar_url)
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
