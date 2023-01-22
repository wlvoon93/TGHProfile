//
//  UserQueryUDS+Mapping.swift
//  Data
//
//  Created by Oleh Kudinov on 12.08.19.
//  Copyright © 2019 Oleh Kudinov. All rights reserved.
//

import Foundation

struct UserQueriesListUDS: Codable {
    var list: [UserQueryUDS]
}

struct UserQueryUDS: Codable {
    let query: String
}

extension UserQueryUDS {
    init(userQuery: UserQuery) {
        query = userQuery.query
    }
}

extension UserQueryUDS {
    func toDomain() -> UserQuery {
        return .init(query: query)
    }
}
