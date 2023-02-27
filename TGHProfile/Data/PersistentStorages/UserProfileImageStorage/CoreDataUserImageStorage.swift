//
//  CoreDataUserProfileImageStorage.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 15/01/2023.
//

import Foundation
import CoreData

final class CoreDataUserImageStorage {

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
    
    private func fetchUserRequest(for userId: Int) -> NSFetchRequest<UserResponseEntity> {
        let request: NSFetchRequest = UserResponseEntity.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %d",
                                                #keyPath(UserResponseEntity.userId), userId)
    
        return request
    }
}

extension CoreDataUserImageStorage: UserProfileImageStorage {
    func loadImage(for userId: Int, completion: @escaping (Result<UsersPageResponseDTO.UserDTO.ProfileImageDTO?, Error>) -> Void) {
        coreDataStorage.performBackgroundTask { context in
            do {
                let fetchRequest = self.fetchUserRequest(for: userId)
                let userEntity = try context.fetch(fetchRequest).first
                let profileImageDTO = userEntity?.profileImage?.toDTO()
                
                completion(.success(profileImageDTO))
            } catch {
                completion(.failure(CoreDataStorageError.readError(error)))
            }
        }
    }
    
    func saveImage(for userId: Int, image: Data, completion: @escaping (VoidResult) -> Void) {
        
        coreDataStorage.performBackgroundTaskQueued { context in
            do {

                let fetchRequest = self.fetchUserRequest(for: userId)
                let userEntity = try context.fetch(fetchRequest).first
                userEntity?.profileImage?.setValue(image, forKey: "image")
                
                try context.save()
                
            } catch {
                completion(.failure(CoreDataStorageError.readError(error)))
            }
        }
    }
    
    func saveImages(for userId: Int, image: Data, invertedImage: Data, completion: @escaping (VoidResult) -> Void) {
        coreDataStorage.performBackgroundTaskQueued { context in
            do {
                let fetchRequest = self.fetchUserRequest(for: userId)
                let userEntity = try context.fetch(fetchRequest).first
                userEntity?.profileImage?.setValue(image, forKey: "image")
                userEntity?.profileImage?.setValue(invertedImage, forKey: "invertedImage")

                try context.save()

                completion(.success)
            } catch {
                completion(.failure(CoreDataStorageError.readError(error)))
            }
        }
    }
}
