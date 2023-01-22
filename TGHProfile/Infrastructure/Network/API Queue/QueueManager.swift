//
//  QueueManager.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 18/01/2023.
//
import Foundation

class QueueManager {
    /// The Lazily-instantiated queue
    lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        return queue;
    }()
    
    /// The Singleton Instance
    static let sharedInstance = QueueManager()
    
    /// Add a single operation
    /// - Parameter operation: The operation to be added
    func enqueue(_ operation: Operation) {
        queue.addOperation(operation)
    }
    
    
    /// Add an array of operations
    /// - Parameter operations: The Array of Operation to be added
    func addOperations(_ operations: [Operation]) {
        queue.addOperations(operations, waitUntilFinished: true)
    }
}
