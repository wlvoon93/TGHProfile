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

    private func fetchRequest(for requestDto: LoadUserNoteRequestDTO) -> NSFetchRequest<UserNoteEntity> {
        let request: NSFetchRequest = UserNoteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %d",
                                        #keyPath(UserNoteEntity.userId), requestDto.userId)
        return request
    }
    
    private func fetchNotesRequest(for userIds: [Int]) -> NSFetchRequest<UserNoteEntity> {
        // search the users table and return all users
//        let fetchRequest = NSFetchRequest<E>(entityName: E.entityName())
        let request: NSFetchRequest = UserNoteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "userId IN %@", userIds)
        
        return request
    }
}

extension CoreDataUserNoteResponseStorage: UserNoteResponseStorage {
    func loadUsersNoteResponse(for userIds: [Int], completion: @escaping (Result<[Note], CoreDataStorageError>) -> Void) {
        let context = coreDataStorage.persistentContainer.viewContext
        context.perform {
            do {
                let fetchRequest = self.fetchNotesRequest(for: userIds)
                let userNoteEntities = try context.fetch(fetchRequest)
                let notes = userNoteEntities.map {
                    Note.init(note: $0.note, userId: Int($0.userId))
                }
                
                completion(.success(notes))
            } catch {
                completion(.failure(CoreDataStorageError.readError(error)))
            }
        }
    }
    
    func loadUserNoteResponse(for request: LoadUserNoteRequestDTO, completion: @escaping (Result<Note?, CoreDataStorageError>) -> Void) {
        let context = coreDataStorage.persistentContainer.viewContext
        context.perform {
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
    
    func saveUserNoteResponse(for request: SaveUserNoteRequestDTO, completion: @escaping (VoidResult) -> Void) {
        coreDataStorage.performBackgroundTaskQueued { context in
            do {
                let fetchRequest = self.fetchRequest(for: LoadUserNoteRequestDTO.init(userId: request.userId))
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
