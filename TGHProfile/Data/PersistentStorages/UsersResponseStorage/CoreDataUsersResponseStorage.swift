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
                                        #keyPath(UsersRequestEntity.per_page), requestDto.per_page)
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
                let fetchRequest = self.fetchRequest(for: requestDto)
                let requestEntity = try context.fetch(fetchRequest).first

                completion(.success(requestEntity?.response?.toDTO()))
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

                try context.save()
            } catch {
                // TODO: - Log to Crashlytics
                debugPrint("CoreDataUsersResponseStorage Unresolved error \(error), \((error as NSError).userInfo)")
            }
        }
    }
}
