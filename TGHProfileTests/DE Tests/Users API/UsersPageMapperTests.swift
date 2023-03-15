//
//  UsersPageMapperTests.swift
//  TGHProfileTests
//
//  Created by T0366-ADE-MB-1 on 16/03/2023.
//

import XCTest
@testable import TGHProfile

class UsersPageMapperTests: XCTestCase {
    func test_map_throwsErrorOnNon200HTTPResponse() throws {
        let json = makeItemsJSON([])
        let samples = [199, 201, 300, 400, 500]
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try UsersPageMapperTests.map(json, from: HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    // helper
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [UsersPageResponseDTO] {
        guard response.isOK, let root = try? JSONDecoder().decode(UsersPageResponseDTO.self, from: data) else {
            throw Error.invalidData
        }
        
        return [root]
    }
    
    public enum Error: Swift.Error {
        case invalidData
    }
}
