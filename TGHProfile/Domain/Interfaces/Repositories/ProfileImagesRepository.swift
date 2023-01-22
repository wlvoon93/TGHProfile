//
//  ProfileImagesRepositoryInterface.swift
//  ExampleMVVM
//
//  Created by T0366-ADE-MB-1 on 16/12/2022.
//

import Foundation

protocol ProfileImagesRepository {
    func fetchImage(with imagePath: String, width: Int, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable?
    func saveImage(userId: Int, imageData: Data, completion: @escaping (VoidResult) -> Void) -> Cancellable?
    func saveInvertedImage(userId: Int, imageData: Data, completion: @escaping (VoidResult) -> Void) -> Cancellable?
}
