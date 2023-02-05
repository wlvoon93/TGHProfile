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
    
    func fetchImage(for userId: Int, imagePath: String, cached: @escaping (ProfileImage) -> Void, completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable? {
        
        let task = RepositoryTask()
        
        cache.loadImage(for: userId) { cache in
            guard !task.isCancelled else { return }

            if case let .success(imageDto?) = cache {
                cached(imageDto.toDomain())
            }

            let endpoint = APIEndpoints.getUserProfile(path: imagePath)
            let task = RepositoryTask()
            task.networkTask = self.dataTransferService.request(with: endpoint) { (result: Result<Data, Error>) in
                guard !task.isCancelled else { return }

                let result = result.mapError { $0 as Error }
                completion(result)
            }
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
    
    func saveImages(userId: Int, imageData: Data, invertedImageData: Data, completion: @escaping (VoidResult) -> Void) -> Cancellable? {
        
        let task = RepositoryTask()
        cache.saveImages(for: userId, image: imageData,  invertedImage: invertedImageData) { result in
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
