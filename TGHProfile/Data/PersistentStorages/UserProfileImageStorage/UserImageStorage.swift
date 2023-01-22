//
//  UserProfileImageStorage.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 15/01/2023.
//

import Foundation

protocol UserProfileImageStorage {
    func saveImage(for userId: Int, image: Data, completion: @escaping (VoidResult) -> Void)
    func saveInvertedImage(for userId: Int, invertedImage: Data, completion: @escaping (VoidResult) -> Void)
}
