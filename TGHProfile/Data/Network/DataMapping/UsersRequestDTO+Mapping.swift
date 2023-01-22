//
//  MoviesRequestDTO+Mapping.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 22/03/2020.
//

import Foundation

struct UsersRequestDTO: Encodable {
    let since: Int
    let per_page: Int
}
