//
//  ApiResultDecodeOperation.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 18/01/2023.
//

import Foundation

class ApiResultDecodeOperation<T: Decodable>: Operation {
    var dataFetched: Data?
    var error: Error?
    var decodedURL: URL?
    typealias CompletionHandler = (_ result: Result<T, DataTransferError>) -> Void
    var completionHandler: (CompletionHandler)?
    typealias NetworkErrorCompletionHandler = (_ result: Result<T, NetworkError>) -> Void
    var networkErrorCompletionHandler: (NetworkErrorCompletionHandler)?
    var decoderInstance: DefaultDataTransferService? = nil
    var decoder: ResponseDecoder?
    
    override func main() {
        if let error = error as? NetworkError,
            let networkErrorCompletionHandler = networkErrorCompletionHandler{
            return networkErrorCompletionHandler(.failure(error))
        }
        guard let dataFetched = dataFetched, let decoder = decoder, let decoderInstance = decoderInstance else {
            cancel()
            return
        }
        let result: Result<T, DataTransferError> = decoderInstance.decode(data: dataFetched, decoder: decoder)

        if let completionHandler = completionHandler {
            completionHandler(result)
        }
    }
}
