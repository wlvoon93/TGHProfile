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

    private func fetchRequest(for requestDto: LoadUserImageRequestDTO) -> NSFetchRequest<UserProfileImageEntity> {
        let request: NSFetchRequest = UserProfileImageEntity.fetchRequest()
        request.predicate = NSPredicate(format: "%K = %d",
                                        #keyPath(UserProfileImageEntity.userId), requestDto.userId)
        return request
    }
}

extension CoreDataUserImageStorage: UserProfileImageStorage {
    func loadImage(for userId: Int, completion: @escaping (Result<UsersPageResponseDTO.UserDTO.ProfileImageDTO?, Error>) -> Void) {
        coreDataStorage.performBackgroundTask { context in
            do {
                let fetchRequest = self.fetchRequest(for: .init(userId: userId))
                let imageEntity = try context.fetch(fetchRequest).first
                let profileImageDTO = imageEntity?.toDTO()
                
                completion(.success(profileImageDTO))
            } catch {
                completion(.failure(CoreDataStorageError.readError(error)))
            }
        }
    }
    
    func saveImage(for userId: Int, image: Data, completion: @escaping (VoidResult) -> Void) {
        
        coreDataStorage.performBackgroundTaskQueued { context in
            do {

                let fetchRequest = self.fetchRequest(for: .init(userId: userId))
                let imageEntity = try context.fetch(fetchRequest).first
                
                if imageEntity == nil {
                    let imageEntity = NSEntityDescription.entity(forEntityName: "UserProfileImageEntity", in : context)!
                    let userImageRecord = NSManagedObject(entity: imageEntity, insertInto: context)
                    
                    userImageRecord.setValue(image, forKey: "image")
                    userImageRecord.setValue(userId, forKey: "userId")
                } else {
                    imageEntity?.setValue(image, forKey: "image")
                }
                
                try context.save()
                
            } catch {
                completion(.failure(CoreDataStorageError.readError(error)))
            }
        }
    }
    
    func saveImages(for userId: Int, image: Data, invertedImage: Data, completion: @escaping (VoidResult) -> Void) {
        coreDataStorage.performBackgroundTaskQueued { context in
            do {
                let fetchRequest = self.fetchRequest(for: .init(userId: userId))
                let imageEntity = try context.fetch(fetchRequest).first
                
                if imageEntity == nil {
                    let imageEntity = NSEntityDescription.entity(forEntityName: "UserProfileImageEntity", in : context)!
                    let userImageRecord = NSManagedObject(entity: imageEntity, insertInto: context)
                    
                    userImageRecord.setValue(image, forKey: "image")
                    userImageRecord.setValue(invertedImage, forKey: "invertedImage")
                    userImageRecord.setValue(userId, forKey: "userId")
                } else {
                    imageEntity?.setValue(image, forKey: "image")
                    imageEntity?.setValue(invertedImage, forKey: "invertedImage")
                }

                try context.save()

                completion(.success)
            } catch {
                completion(.failure(CoreDataStorageError.readError(error)))
            }
        }
    }
}
