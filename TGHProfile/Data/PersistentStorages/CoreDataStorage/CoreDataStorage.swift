//
//  CoreDataStorage.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 26/03/2020.
//

import CoreData

enum CoreDataStorageError: Error {
    case readError(Error)
    case saveError(Error)
    case deleteError(Error)
}

final class CoreDataStorage {

    static let shared = CoreDataStorage()
    let persistentContainerQueue = OperationQueue()
    
    private init() {}

    // MARK: - Core Data stack
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataStorage")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // TODO: - Log to Crashlytics
                assertionFailure("CoreDataStorage Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // TODO: - Log to Crashlytics
                assertionFailure("CoreDataStorage Unresolved error \(error), \((error as NSError).userInfo)")
            }
        }
    }

    func performBackgroundTaskQueued(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainerQueue.maxConcurrentOperationCount = 1
        persistentContainerQueue.addOperation(){
            let context: NSManagedObjectContext = self.persistentContainer.newBackgroundContext()
            context.performAndWait{
                block(context)
            }
        }
    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainerQueue.maxConcurrentOperationCount = 1
        persistentContainerQueue.addOperation(){
            let context: NSManagedObjectContext = self.persistentContainer.newBackgroundContext()
            context.performAndWait{
                block(context)
            }
        }
    }
}
