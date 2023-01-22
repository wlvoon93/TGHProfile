//
//  DefaultUserNoteRepository.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 08/01/2023.
//

import Foundation

final class DefaultUserNoteRepository {

    private let cache: UserNoteResponseStorage

    init(cache: UserNoteResponseStorage) {
        self.cache = cache
    }
}

extension DefaultUserNoteRepository: UserNoteRepository {
    
    func getUserNoteResponse(userId: Int, completion: @escaping (Result<Note, Error>) -> Void) -> Cancellable? {
        
        let task = RepositoryTask()
        
        return task
    }
    
    func saveUserNoteResponse(userId: Int, note: String, completion: @escaping (VoidResult) -> Void) -> Cancellable? {
        
        let task = RepositoryTask()
        cache.saveUserNoteResponse(for: UserNoteRequestDTO.init(userId: userId, note: note)) { result in
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
