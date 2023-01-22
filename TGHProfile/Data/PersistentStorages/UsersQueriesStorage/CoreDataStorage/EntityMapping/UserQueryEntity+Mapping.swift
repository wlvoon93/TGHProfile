//
//  UserQueryEntity+Mapping.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 16.08.19.
//

import Foundation
import CoreData

extension UserQueryEntity {
    convenience init(userQuery: UserQuery, insertInto context: NSManagedObjectContext) {
        self.init(context: context)
        query = userQuery.query
        createdAt = Date()
    }
}

extension UserQueryEntity {
    func toDomain() -> UserQuery {
        return .init(query: query ?? "")
    }
}
