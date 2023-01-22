//
//  DataTransfer.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//

import Foundation

public enum DataTransferError: Error {
    case noResponse
    case parsing(Error)
    case networkFailure(NetworkError)
    case resolvedNetworkFailure(Error)
}

public protocol DataTransferService {
    typealias CompletionHandler<T> = (Result<T, Error>) -> Void
    
    @discardableResult
    func requestAll<T: Decodable, E: ResponseRequestable>(with endpoint: E,
                                                              completion: @escaping CompletionHandler<[T]>) -> NetworkCancellable? where E.Response == T
    
    @discardableResult
    func request<T: Decodable, E: ResponseRequestable>(with endpoint: E,
                                                       completion: @escaping CompletionHandler<T>) -> NetworkCancellable? where E.Response == T
}

public protocol DataTransferErrorResolver {
    func resolve(error: NetworkError) -> Error
}

public protocol ResponseDecoder {
    func decode<T: Decodable>(_ data: Data) throws -> T
}

public protocol DataTransferErrorLogger {
    func log(error: Error)
}

public class DefaultDataTransferService {
    
    private let networkService: NetworkService
    private let errorResolver: DataTransferErrorResolver
    private let errorLogger: DataTransferErrorLogger
    private let queueManager: QueueManager = QueueManager.sharedInstance
    
    public init(with networkService: NetworkService,
                errorResolver: DataTransferErrorResolver = DefaultDataTransferErrorResolver(),
                errorLogger: DataTransferErrorLogger = DefaultDataTransferErrorLogger()) {
        self.networkService = networkService
        self.errorResolver = errorResolver
        self.errorLogger = errorLogger
    }
}

extension DefaultDataTransferService: DataTransferService {
        
    public func request<T: Decodable, E: ResponseRequestable>(with endpoint: E,
                                                              completion: @escaping CompletionHandler<T>) -> NetworkCancellable? where E.Response == T {
        
        let fetch = ApiRetrievalOperation(url: endpoint, httpManager: self.networkService)
        let parse = ApiResultDecodeOperation<T>()
        
        let adapter = BlockOperation() { [unowned fetch, unowned parse, weak self] in
            guard let self = self else { return }
            parse.dataFetched = fetch.dataFetched
            parse.error = fetch.error
            parse.decoderInstance = self
            parse.decoder = endpoint.responseDecoder
        }
        
        adapter.addDependency(fetch)
        parse.addDependency(adapter)
        
        parse.networkErrorCompletionHandler = { result in
            switch result {
            case .success(let data):
                return completion(.success(data))
            case .failure(let error):
                return completion(.failure(error))
            }
        }
        
        parse.completionHandler = { result in
            switch result {
            case .success(let data):
                return completion(.success(data))
            case .failure(let error):
                return completion(.failure(error))
            }
        }
        queueManager.addOperations([fetch, parse, adapter])
        
        return fetch.requestCancellable
    }
    
    public func requestAll<T: Decodable, E: ResponseRequestable>(with endpoint: E,
                                                              completion: @escaping CompletionHandler<[T]>) -> NetworkCancellable? where E.Response == T {

        let fetch = ApiRetrievalOperation(url: endpoint, httpManager: self.networkService)
        let parse = ApiResultDecodeOperation<[T]>()
        
        let adapter = BlockOperation() { [unowned fetch, unowned parse, weak self] in
            guard let self = self else { return }
            parse.dataFetched = fetch.dataFetched
            parse.error = fetch.error
            parse.decoderInstance = self
            parse.decoder = endpoint.responseDecoder
        }
        
        adapter.addDependency(fetch)
        parse.addDependency(adapter)
        
        parse.networkErrorCompletionHandler = { result in
            switch result {
            case .success(let data):
                return completion(.success(data))
            case .failure(let error):
                return completion(.failure(error))
            }
        }
        
        parse.completionHandler = { result in
            switch result {
            case .success(let data):
                return completion(.success(data))
            case .failure(let error):
                return completion(.failure(error))
            }
        }
        queueManager.addOperations([fetch, parse, adapter])
        
        return fetch.requestCancellable
    }

    // MARK: - Private
    func decode<T: Decodable>(data: Data?, decoder: ResponseDecoder) -> Result<T, DataTransferError> {
        do {
            print(String(describing: T.self))
            guard let data = data else { return .failure(.noResponse) }
            let result: T = try decoder.decode(data)
            return .success(result)
        } catch {
            self.errorLogger.log(error: error)
            return .failure(.parsing(error))
        }
    }
    
    private func decodeList<T: Decodable>(data: Data?, decoder: ResponseDecoder) -> Result<[T], DataTransferError> {
        do {
            print(String(describing: [T].self))
            guard let data = data else { return .failure(.noResponse) }
            let result: [T] = try decoder.decode(data)
            return .success(result)
        } catch {
            self.errorLogger.log(error: error)
            return .failure(.parsing(error))
        }
    }
    
    private func resolve(networkError error: NetworkError) -> DataTransferError {
        let resolvedError = self.errorResolver.resolve(error: error)
        return resolvedError is NetworkError ? .networkFailure(error) : .resolvedNetworkFailure(resolvedError)
    }
}

// MARK: - Logger
public final class DefaultDataTransferErrorLogger: DataTransferErrorLogger {
    public init() { }
    
    public func log(error: Error) {
        printIfDebug("-------------")
        printIfDebug("\(error)")
    }
}

// MARK: - Error Resolver
public class DefaultDataTransferErrorResolver: DataTransferErrorResolver {
    public init() { }
    public func resolve(error: NetworkError) -> Error {
        return error
    }
}

// MARK: - Response Decoders
public class JSONResponseDecoder: ResponseDecoder {
    private let jsonDecoder = JSONDecoder()
    public init() { }
    public func decode<T: Decodable>(_ data: Data) throws -> T {
        return try jsonDecoder.decode(T.self, from: data)
    }
}

public class RawDataResponseDecoder: ResponseDecoder {
    public init() { }
    
    enum CodingKeys: String, CodingKey {
        case `default` = ""
    }
    public func decode<T: Decodable>(_ data: Data) throws -> T {
        if T.self is Data.Type, let data = data as? T {
            return data
        } else {
            let context = DecodingError.Context(codingPath: [CodingKeys.default], debugDescription: "Expected Data type")
            throw Swift.DecodingError.typeMismatch(T.self, context)
        }
    }
}
