//
//  CoreDataUsersResponseStorage.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 05/04/2020.
//

import Foundation
import CoreData

final class CoreDataUsersResponseStorage {

    private let coreDataStorage: CoreDataStorage

    init(coreDataStorage: CoreDataStorage = CoreDataStorage.shared) {
        self.coreDataStorage = coreDataStorage
    }

    // MARK: - Private

    private func fetchRequest(for requestDto: UsersRequestDTO) -> NSFetchRequest<UsersRequestEntity> {
        let request: NSFetchRequest = UsersRequestEntity.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %d AND %K = %d",
                                        #keyPath(UsersRequestEntity.since), requestDto.since,
                                        #keyPath(UsersRequestEntity.perPage), requestDto.per_page)
        return request
    }
    
    // currently is search since:0 AND per_page:5 but need to modify into directly query users
    // search result mode ( turn off scroll to load more ) until x is pressed.
    private func fetchSearchRequest(for requestDto: UsersSearchRequestDTO) -> NSFetchRequest<UserResponseEntity> {
        // search the users table and return all users
        let request: NSFetchRequest = UserResponseEntity.fetchRequest()
//        request.predicate = NSPredicate(format: "%K = %@",
//                                        #keyPath(UserResponseEntity.login), requestDto.query)
        return request
    }
    
    private func fetchNotesRequest(for users: [UsersPageResponseDTO.UserDTO]) -> NSFetchRequest<UserNoteEntity> {
        // search the users table and return all users
        let userIDs = Set(users.map { $0.id })
//        let fetchRequest = NSFetchRequest<E>(entityName: E.entityName())
        let request: NSFetchRequest = UserNoteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "userId IN %@", userIDs)
        
        return request
    }
    
    private func fetchNoteRequest(for user: UsersPageResponseDTO.UserDTO) -> NSFetchRequest<UserNoteEntity> {
        let request: NSFetchRequest = UserNoteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %i",
                                                #keyPath(UserNoteEntity.userId), user.id)
    
        return request
    }

    private func deleteResponse(for requestDto: UsersRequestDTO, in context: NSManagedObjectContext) {
        let request = fetchRequest(for: requestDto)

        do {
            if let result = try context.fetch(request).first {
                context.delete(result)
            }
        } catch {
            print(error)
        }
    }
}

extension CoreDataUsersResponseStorage: UsersResponseStorage {

    func getResponse(for requestDto: UsersRequestDTO, completion: @escaping (Result<UsersPageResponseDTO?, CoreDataStorageError>) -> Void) {
        coreDataStorage.performBackgroundTask { context in
            do {
                let fetchUsersPageRequest = self.fetchRequest(for: requestDto)
                let requestUsersPageEntity = try context.fetch(fetchUsersPageRequest).first
                let userPageResponseDTO = requestUsersPageEntity?.response?.toDTO()
                
                var userDTOs:[UsersPageResponseDTO.UserDTO] = []
                if let userPageResponseDTO = userPageResponseDTO {
                    // put note dto into response page dto
                    let fetchNotesRequest = self.fetchNotesRequest(for: userPageResponseDTO.users)
                    let userNoteEntities = try context.fetch(fetchNotesRequest)
                    for user in userPageResponseDTO.users{
                        for note in userNoteEntities {
                            if note.userId == user.id {
                                
                                let userDTO = UsersPageResponseDTO.UserDTO.init(login: user.login, id: user.id, avatar_url: user.avatar_url, type: user.type, note: UsersPageResponseDTO.UserDTO.NoteDTO.init(note: note.note, userId: Int(note.userId)))
                                userDTOs.append(userDTO)
                            }
                        }
                    }
                    // check is note updated
                    let userPageResponseDTOWithNote = UsersPageResponseDTO.init(since: userPageResponseDTO.since, per_page: userPageResponseDTO.per_page, users: userDTOs)
                    
                    completion(.success(userPageResponseDTOWithNote))
                }else{
                    completion(.success(userPageResponseDTO))
                }
            } catch {
                completion(.failure(CoreDataStorageError.readError(error)))
            }
        }
    }
    
    func getSearchResponse(for requestDto: UsersSearchRequestDTO, completion: @escaping (Result<UsersPageResponseDTO?, CoreDataStorageError>) -> Void) {
        coreDataStorage.performBackgroundTask { context in
            do {
                let fetchRequest = self.fetchSearchRequest(for: requestDto)
                let userResponseEntities = try context.fetch(fetchRequest)
                let userWithoutNoteDTOs = userResponseEntities.map { UsersPageResponseDTO.UserDTO.init(login: $0.login, id: Int($0.id), avatar_url: $0.avatarUrl, type: $0.type, note: nil) }
                let fetchNotesRequest = self.fetchNotesRequest(for: userWithoutNoteDTOs)
                let userNoteEntities = try context.fetch(fetchNotesRequest)
                var userWithNoteDTOs:[UsersPageResponseDTO.UserDTO] = []
                for user in userWithoutNoteDTOs {
                    for note in userNoteEntities {
                        if note.userId == user.id {
                            
                            let userDTO = UsersPageResponseDTO.UserDTO.init(login: user.login, id: user.id, avatar_url: user.avatar_url, type: user.type, note: UsersPageResponseDTO.UserDTO.NoteDTO.init(note: note.note, userId: Int(note.userId)))
                            userWithNoteDTOs.append(userDTO)
                        }
                    }
                }
                
                let usersPageResponseDTO = UsersPageResponseDTO.init(since: 0, per_page: userResponseEntities.count, users: userWithNoteDTOs)
                completion(.success(usersPageResponseDTO))
            } catch {
                completion(.failure(CoreDataStorageError.readError(error)))
            }
        }
    }
    
    func getNotesResponse(for users: [UsersPageResponseDTO.UserDTO], completion: @escaping (Result<[Note], CoreDataStorageError>) -> Void) {
        coreDataStorage.performBackgroundTask { context in
            do {
                let fetchRequest = self.fetchNotesRequest(for: users)
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

    func save(response responseDto: UsersPageResponseDTO, for requestDto: UsersRequestDTO) {
        coreDataStorage.performBackgroundTask { context in
            do {
                self.deleteResponse(for: requestDto, in: context)

                let requestEntity = requestDto.toEntity(in: context)
                requestEntity.response = responseDto.toEntity(in: context)
                // create note for all users
                for user in responseDto.users {
                    // if already exist, don't save
                    let fetchRequest = self.fetchNoteRequest(for: user)
                    let userNoteEntityExist = try context.fetch(fetchRequest)
                    if userNoteEntityExist.first != nil { continue }
                    
                    let userNoteEntity = NSEntityDescription.entity(forEntityName: "UserNoteEntity", in : context)!
                    let userNoteRecord = NSManagedObject(entity: userNoteEntity, insertInto: context)
                    userNoteRecord.setValue(nil, forKey: "note")
                    userNoteRecord.setValue(user.id, forKey: "userId")
                }
                
                try context.save()
            } catch {
                // TODO: - Log to Crashlytics
                debugPrint("CoreDataUsersResponseStorage Unresolved error \(error), \((error as NSError).userInfo)")
            }
        }
    }
}
