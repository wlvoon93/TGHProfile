//
//  NetworkOperation.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 18/01/2023.
//

import Foundation

class NetworkOperation: Operation {
    typealias OperationCompletionHandler = (_ result: Result<Data?, NetworkError>) -> Void
    
    /// The completionHandler that is run when the operation is complete
    var completionHandler: (OperationCompletionHandler)?
    
    /// Stte stored as an enum
    private enum State: String {
        case ready = "isReady"
        case executing = "isExecuting"
        case finished = "isFinished"
    }
    
    private var state = State.ready {
        willSet {
            willChangeValue(forKey: newValue.rawValue)
            willChangeValue(forKey: state.rawValue)
        }
        didSet {
            didChangeValue(forKey: oldValue.rawValue)
            didChangeValue(forKey: state.rawValue)
        }
    }
    
    override var isReady: Bool {
        return super.isReady && state == .ready
    }
    
    override var isExecuting: Bool {
        return state == .executing
    }
    
    override var isFinished: Bool {
        return state == .finished
    }
    
    /// Start the NSOperation
    override func start() {
        guard !isCancelled else {
            finish()
            return
        }
        if !isExecuting {
            state = .executing
        }
        main()
    }
    
    /// Move to the finished state
    func finish() {
        if isExecuting {
            state = .finished
        }
    }
    
    /// Called to indicate that the operation is complete, and then call the opional completion handler
    /// - Parameter result: The result type
    func complete(result: Result<Data?, NetworkError>) {
        finish()
        if !isCancelled {
            completionHandler?(result)
        }
    }
    
    /// Cancels the Operation
    override func cancel() {
        super.cancel()
        finish()
    }
}
