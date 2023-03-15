//
//  User+Stub.swift
//  TGHProfileTests
//
//  Created by T0366-ADE-MB-1 on 11/01/2023.
//

import Foundation
@testable import TGHProfile

extension User {
    static func stub(login: String = "",
                        id: Int = 10 ,
                        profileImage: ProfileImage = ProfileImage.init(image: nil, invertedImage: nil),
                        avatar_url: String,
                        type: String = "",
                        note: Note = Note(note: "inval note", userId: -1)) -> Self {
        User(login: login,
             userId: id,
             profileImage: profileImage,
             imageUrl: avatar_url,
             type: type,
             note: note,
             following: nil,
             followers: nil,
             company: nil,
             blog: nil)
    }
}
