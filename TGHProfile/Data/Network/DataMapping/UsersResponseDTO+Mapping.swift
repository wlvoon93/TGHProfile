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
    let login: String?
    let id: Int
    let avatar_url: String?
    let type: String?
}


// MARK: - Mappings to Domain

extension UsersResponseDTO {
    func toDomain() -> User {
        return .init(login: login, id: id, avatar_url: avatar_url, type: type)
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
