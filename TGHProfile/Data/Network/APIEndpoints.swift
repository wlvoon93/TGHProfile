//
//  APIEndpoints.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

struct APIEndpoints {
    
    static func getUsers(with usersRequestDTO: UsersRequestDTO) -> Endpoint<UsersResponseDTO> {

        return Endpoint(path: "users",
                        method: .get,
                        queryParametersEncodable: usersRequestDTO)
    }
    
    static func getUserDetails(with usersDetailsRequestDTO: UserDetailsRequestDTO) -> Endpoint<UserDetailsResponseDTO> {

        return Endpoint(path: "users/\(usersDetailsRequestDTO.username)",
                        method: .get)
    }

    static func getUserProfile(path: String) -> Endpoint<Data> {
        return Endpoint(path: path,
                        isFullPath: true,
                        method: .get,
                        responseDecoder: RawDataResponseDecoder())
    }
}
