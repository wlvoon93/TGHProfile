//
//  UsersListDataTransferService.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 26/12/2022.
//

import Foundation

//public final class UsersListDataTransferService: DefaultDataTransferService {
//    public func requestDTO<T: Decodable, E: ResponseRequestable>(with endpoint: E,
//                                                              completion: @escaping CompletionHandler<[T]>) -> NetworkCancellable? where E.Response == T {
//
//        return self.networkService.request(endpoint: endpoint) { result in
//            switch result {
//            case .success(let data):
//                
//                let result: Result<[T], DataTransferError> = self.decodeList(data: data, decoder: endpoint.responseDecoder)
//                DispatchQueue.main.async { return completion(result) }
//            case .failure(let error):
//                self.errorLogger.log(error: error)
//                let error = self.resolve(networkError: error)
//                DispatchQueue.main.async { return completion(.failure(error)) }
//            }
//        }
//    }
//}
