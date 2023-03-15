//
//  HTTPURLResponse+StatusCode.swift
//  TGHProfileTests
//
//  Created by T0366-ADE-MB-1 on 16/03/2023.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }
    
    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
