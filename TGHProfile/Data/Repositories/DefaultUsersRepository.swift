//
//  DefaultUsersRepository.swift
//  ExampleMVVM
//
//  Created by Oleh Kudinov on 01.10.18.
//
// **Note**: DTOs structs are mapped into Domains here, and Repository protocols does not contain DTOs

import Foundation

final class DefaultUsersRepository {

    private let dataTransferService: DataTransferService
    private let cache: UsersResponseStorage

    init(dataTransferService: DataTransferService, cache: UsersResponseStorage) {
        self.dataTransferService = dataTransferService
        self.cache = cache
    }
}

extension DefaultUsersRepository: UsersRepository {

    public func fetchAllUsersList(page: Int,
                                  cached: @escaping (UsersPage) -> Void,
                                  completion: @escaping (Result<UsersPage, Error>) -> Void) -> Cancellable? {

        let requestDTO = UsersRequestDTO(since: page*10, per_page: 10)
        let task = RepositoryTask()

        cache.getResponse(for: requestDTO) { result in

            if case let .success(responseDTO?) = result {
                cached(responseDTO.toDomain())
            }
            guard !task.isCancelled else { return }

            let endpoint = APIEndpoints.getUsers(with: requestDTO)
            task.networkTask = self.dataTransferService.requestAll(with: endpoint, completion: { result in
                switch result {
                case .success(let responseDTOs):
                    // use, UsersResponse DTO
                    // convert array(responseDTOs) into UserPageDTO
                    if let responseDTOsCasted = responseDTOs as? [UsersResponseDTO] {
                        let users = responseDTOsCasted.map {
                            UsersPageResponseDTO.UserDTO.init(login: $0.login, id: $0.id, avatar_url: $0.avatar_url, type: $0.type, note: nil, following: nil, followers: nil, company: nil, blog: nil) }
                        let usersPageResponseDTO = UsersPageResponseDTO.init(since: requestDTO.since, per_page: requestDTO.per_page, users: users)
                        self.cache.save(response: usersPageResponseDTO, for:requestDTO)
                        completion(.success(usersPageResponseDTO.toDomain()))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
        return task
    }

    // search user locally
    public func searchUsersList(query: String,
                                completion: @escaping (Result<UsersPage, Error>) -> Void) -> Cancellable? {

        let requestDTO = UsersSearchRequestDTO(query: query)
        let task = RepositoryTask()

        cache.getSearchResponse(for: requestDTO) { result in

            if case let .success(responseDTO?) = result {
                completion(.success(responseDTO.toDomain()))
            }
            
            switch result {
            case .success(let responseDTOs):
                // use, UsersResponse DTO
                // convert array(responseDTOs) into UserPageDTO
                if let responseDTOsCasted = responseDTOs as? [UsersResponseDTO] {
                    let users = responseDTOsCasted.map { UsersPageResponseDTO.UserDTO.init(login: $0.login, id: $0.id, avatar_url: $0.avatar_url, type: $0.type, note: nil, following: nil, followers: nil, company: nil, blog: nil) }
                    let usersPageResponseDTO = UsersPageResponseDTO.init(since: 0, per_page: users.count, users: users)
                    completion(.success(usersPageResponseDTO.toDomain()))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }
    
    func fetchUserDetails(query: UserDetailsQuery,
                          completion: @escaping (Result<User, Error>) -> Void) -> Cancellable? {
        let requestDTO = UserDetailsRequestDTO(username: query.username)
        let task = RepositoryTask()

        cache.getUserDetailsResponse(for: requestDTO) { result in

            if case let .success(responseDTO?) = result {
                printIfDebug("User \(String(describing: responseDTO.login)) saved.")
            }
            guard !task.isCancelled else { return }

            let endpoint = APIEndpoints.getUserDetails(with: requestDTO)
            task.networkTask = self.dataTransferService.request(with: endpoint, completion: { result in
                switch result {
                case .success(let responseDTO):
                    self.cache.updateUser(response: responseDTO, for: requestDTO)
                    completion(.success(responseDTO.toDomain()))
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
        return task
    }
}
