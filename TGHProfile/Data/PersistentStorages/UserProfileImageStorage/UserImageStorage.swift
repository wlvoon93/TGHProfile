//
//  UserProfileImageStorage.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 15/01/2023.
//

import Foundation

protocol UserProfileImageStorage {
    func loadImage(for userId: Int, completion: @escaping (Result<UsersPageResponseDTO.UserDTO.ProfileImageDTO?, Error>) -> Void)
    func saveImage(for userId: Int, image: Data, completion: @escaping (VoidResult) -> Void)
    func saveImages(for userId: Int, image: Data, invertedImage: Data, completion: @escaping (VoidResult) -> Void)
}
