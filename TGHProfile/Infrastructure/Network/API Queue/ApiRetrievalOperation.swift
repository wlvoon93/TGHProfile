//
//  UserListRetrievalOperation.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 18/01/2023.
//

import Foundation

class ApiRetrievalOperation<T: Decodable, E: ResponseRequestable>: NetworkOperation where E.Response == T {
    var dataFetched: Data?
    var httpManager: NetworkService
    var error: Error?
    var url: E
    var requestCancellable: NetworkCancellable?
    
    init(url: E, httpManager: NetworkService) {
        self.url = url
        self.httpManager = httpManager
    }
       
    override func main() {
        requestCancellable = httpManager.request(endpoint: url, completion: { result in
            switch result {
            case .failure(let error):
                self.error = error
                self.complete(result: result)
            case .success(let successdata):
                self.dataFetched = successdata
                self.complete(result: result)
            }
        })
    }
}
