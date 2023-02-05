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
        request.predicate = NSPredicate(format: "%K = %d",
                                        #keyPath(UsersRequestEntity.since), requestDto.since)
        return request
    }
    
    private func fetchUsersWithIdRequest(for requestDto: FetchUsersWithIdsRequestDTO) -> NSFetchRequest<UserResponseEntity> {
        let request: NSFetchRequest = UserResponseEntity.fetchRequest()
        request.predicate = NSPredicate(format: "userId IN %@", requestDto.ids)
        return request
    }
    
    private func fetchUserDetailsResponse(for requestDto: UserDetailsRequestDTO) -> NSFetchRequest<UserResponseEntity> {
        let request: NSFetchRequest = UserResponseEntity.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %@",
                                        #keyPath(UserResponseEntity.login), requestDto.username)
        return request
    }
    
    private func fetchNotesWithUsernameAndNoteKeywordRequest(for requestDto: LoadUsersWithUsernameAndNoteKeywordRequestDTO) -> NSFetchRequest<UserNoteEntity> {
        // search the users table and return all users
        let request: NSFetchRequest = UserNoteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "(%K CONTAINS[cd] %@) OR (%K CONTAINS[cd] %@)",
                                        #keyPath(UserNoteEntity.username),
                                        requestDto.query,
                                        #keyPath(UserNoteEntity.note),
                                        requestDto.query)
        return request
    }
    
    private func fetchNotesRequest(for users: [UsersPageResponseDTO.UserDTO]) -> NSFetchRequest<UserNoteEntity> {
        let userIDs = Set(users.map { $0.id })
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
        let context = coreDataStorage.persistentContainer.viewContext
        
        DispatchQueue.main.async {
            
            do {
                let fetchUsersPageRequest = self.fetchRequest(for: requestDto)
                let requestUsersPageEntity = try context.fetch(fetchUsersPageRequest).first
                let userPageResponseDTO = requestUsersPageEntity?.response?.toDTO()
                
                var userDTOs:[UsersPageResponseDTO.UserDTO] = []
                if let userPageResponseDTO = userPageResponseDTO {
                    // put note dto into response page dto
                    let fetchNotesRequest = self.fetchNotesRequest(for: userPageResponseDTO.users)
                    let userNoteEntities = try context.fetch(fetchNotesRequest)
                    // sort the users
                    let sortedUsers = userPageResponseDTO.users.sorted()
                    for user in sortedUsers{
                        for note in userNoteEntities {
                            if note.userId == user.id {
                                
                                let userDTO = UsersPageResponseDTO.UserDTO.init(login: user.login,
                                                                                id: user.id,
                                                                                profileImage: UsersPageResponseDTO.UserDTO.ProfileImageDTO.init(imageUrl: user.profileImage?.imageUrl, image: user.profileImage?.image, invertedImage: user.profileImage?.invertedImage),
                                                                                type: user.type,
                                                                                note: UsersPageResponseDTO.UserDTO.NoteDTO.init(note: note.note, userId: Int(note.userId)),
                                                                                following: nil,
                                                                                followers: nil,
                                                                                company: nil, blog: nil)
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
    
    // fetch related note and username here
    func searchUsersWithUsernameAndNoteKeyword(for requestDto: LoadUsersWithUsernameAndNoteKeywordRequestDTO, completion: @escaping (Result<UsersPageResponseDTO?, CoreDataStorageError>) -> Void) {
        let context = coreDataStorage.persistentContainer.viewContext
        do { // result will be notes
            let fetchRequest = self.fetchNotesWithUsernameAndNoteKeywordRequest(for: requestDto)
            let noteEntities = try context.fetch(fetchRequest)
            
            // fetch users with notes id
            // fit the notes into the users
            let userIds = noteEntities.map { return Int($0.userId) }
            let fetchUsersRequestDto = FetchUsersWithIdsRequestDTO.init(ids: userIds)
            let fetchUsersRequest = self.fetchUsersWithIdRequest(for: fetchUsersRequestDto)
            let userEntities = try context.fetch(fetchUsersRequest)
            let userDTOs = userEntities.map { return $0.toDTO() }
            
            var userWithNoteDTOs:[UsersPageResponseDTO.UserDTO] = []
            let sortedUsers = userDTOs.sorted()
            for user in sortedUsers{
                let noteEntity = noteEntities.filter { return $0.userId == user.id }.first
                let userDTO = UsersPageResponseDTO.UserDTO.init(login: user.login,
                                                                id: user.id,
                                                                profileImage: UsersPageResponseDTO.UserDTO.ProfileImageDTO.init(imageUrl: user.profileImage?.imageUrl, image: user.profileImage?.image, invertedImage: user.profileImage?.invertedImage),
                                                                type: user.type,
                                                                note: UsersPageResponseDTO.UserDTO.NoteDTO.init(note: noteEntity?.note, userId: Int(user.id)),
                                                                following: nil,
                                                                followers: nil,
                                                                company: nil, blog: nil)
                userWithNoteDTOs.append(userDTO)
            }
            
            let userPageResponseDTOWithNote = UsersPageResponseDTO.init(since: 0, per_page: 99, users: userDTOs)

            completion(.success(userPageResponseDTOWithNote))
        } catch {
            completion(.failure(CoreDataStorageError.readError(error)))
        }
    }
    
    func getNotesResponse(for users: [UsersPageResponseDTO.UserDTO], completion: @escaping (Result<[Note], CoreDataStorageError>) -> Void) {
        let context = coreDataStorage.persistentContainer.viewContext
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
    
    func getUserDetailsResponse(for requestDto: UserDetailsRequestDTO, completion: @escaping (Result<UsersPageResponseDTO.UserDTO?, CoreDataStorageError>) -> Void) {
        let context = coreDataStorage.persistentContainer.viewContext
        do {
            let fetchUserDetailsRequest = self.fetchUserDetailsResponse(for: requestDto)
            let requestUserDetailsEntity = try context.fetch(fetchUserDetailsRequest).first
            let userDetailsDTO = requestUserDetailsEntity?.toDTO()
            
            completion(.success(userDetailsDTO))
        } catch {
            completion(.failure(CoreDataStorageError.readError(error)))
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
                    userNoteRecord.setValue(user.login, forKey: "username")
                    userNoteRecord.setValue(user.id, forKey: "userId")
                }

                try context.save()
            } catch {
                // TODO: - Log to Crashlytics
                debugPrint("CoreDataUsersResponseStorage Unresolved error \(error), \((error as NSError).userInfo)")
            }
        }
    }
    
    func updateUser(response responseDto: UserDetailsResponseDTO, for requestDto: UserDetailsRequestDTO) {
        coreDataStorage.performBackgroundTask { context in
            do {
                let fetchUserDetailsRequest = self.fetchUserDetailsResponse(for: requestDto)
                let requestUserDetailsEntity = try context.fetch(fetchUserDetailsRequest).first
                requestUserDetailsEntity?.profileImage?.setValue(responseDto.avatar_url, forKey: "imageUrl")
                requestUserDetailsEntity?.setValue(responseDto.id, forKey: "userId")
                requestUserDetailsEntity?.setValue(responseDto.type, forKey: "type")
                requestUserDetailsEntity?.setValue(responseDto.followers, forKey: "followers")
                requestUserDetailsEntity?.setValue(responseDto.following, forKey: "following")
                requestUserDetailsEntity?.setValue(responseDto.company, forKey: "company")
                requestUserDetailsEntity?.setValue(responseDto.blog, forKey: "blog")
                
                
                try context.save()
            } catch {
                // TODO: - Log to Crashlytics
                debugPrint("CoreDataUsersResponseStorage Unresolved error \(error), \((error as NSError).userInfo)")
            }
        }
    }
}
