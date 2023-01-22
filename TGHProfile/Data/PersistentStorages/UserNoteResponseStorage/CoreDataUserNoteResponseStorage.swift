//
//  CoreDataUserNoteResponseStorage.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 08/01/2023.
//

import Foundation
import CoreData

final class CoreDataUserNoteResponseStorage {

    private let coreDataStorage: CoreDataStorage

    init(coreDataStorage: CoreDataStorage = CoreDataStorage.shared) {
        self.coreDataStorage = coreDataStorage
    }

    // MARK: - Private

    private func fetchRequest(for requestDto: UserNoteRequestDTO) -> NSFetchRequest<UserNoteEntity> {
        let request: NSFetchRequest = UserNoteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %d",
                                        #keyPath(UserNoteEntity.userId), requestDto.userId)
        return request
    }
}

extension CoreDataUserNoteResponseStorage: UserNoteResponseStorage {
    func getUserNoteResponse(for request: UserNoteRequestDTO, completion: @escaping (Result<Note?, CoreDataStorageError>) -> Void) {
        coreDataStorage.performBackgroundTask { context in
            do {
                let fetchRequest = self.fetchRequest(for: request)
                let userNoteEntity = try context.fetch(fetchRequest).first
                let userNoteDTO = userNoteEntity?.toDomain()
                completion(.success(userNoteDTO))
            } catch {
                completion(.failure(CoreDataStorageError.readError(error)))
            }
        }
    }
    
    func saveUserNoteResponse(for request: UserNoteRequestDTO, completion: @escaping (VoidResult) -> Void) {
        coreDataStorage.performBackgroundTask { context in
            do {
                let fetchRequest = self.fetchRequest(for: request)
                let userNoteEntity = try context.fetch(fetchRequest).first
                
                userNoteEntity?.setValue(request.note, forKey: "note")
                
                try context.save()
                completion(.success)
            } catch {
                completion(.failure(CoreDataStorageError.readError(error)))
            }
        }
    }
}
