//
//  MoviesRequestDTO+Mapping.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 22/03/2020.
//

import Foundation

struct UsersRequestDTO: Encodable {
    let query: String
    let page: Int
}
