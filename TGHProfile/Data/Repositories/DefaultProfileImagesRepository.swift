//
//  DefaultProfileImagesRepository.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

final class DefaultProfileImagesRepository {
    
    private let dataTransferService: DataTransferService
    private let cache: UserProfileImageStorage

    init(dataTransferService: DataTransferService, cache: UserProfileImageStorage) {
        self.dataTransferService = dataTransferService
        self.cache = cache
    }
}

extension DefaultProfileImagesRepository: ProfileImagesRepository {
    
    func fetchImage(with imagePath: String, width: Int, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable? {
        
        let endpoint = APIEndpoints.getUserProfile(path: imagePath)
        let task = RepositoryTask()
        task.networkTask = dataTransferService.request(with: endpoint) { (result: Result<Data, DataTransferError>) in

            let result = result.mapError { $0 as Error }
            DispatchQueue.main.async { completion(result) }
        }
        return task
    }
    
    func saveImage(userId: Int, imageData: Data, completion: @escaping (VoidResult) -> Void) -> Cancellable? {
        
        let task = RepositoryTask()
        cache.saveImage(for: userId, image: imageData) { result in
            guard !task.isCancelled else { return }
            
            switch result {
            case .success:
                completion(.success)
            case .failure(let error):
                completion(.failure(error))
            }
        }

        return task
    }
    
    func saveInvertedImage(userId: Int, imageData: Data, completion: @escaping (VoidResult) -> Void) -> Cancellable? {
        
        let task = RepositoryTask()
        cache.saveInvertedImage(for: userId, invertedImage: imageData) { result in
            guard !task.isCancelled else { return }
            
            switch result {
            case .success:
                completion(.success)
            case .failure(let error):
                completion(.failure(error))
            }
        }

        return task
    }
}
