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
    
    public func fetchAllUsersList(since: Int,
                                  per_page: Int?, // get per page of since 0, if nil then determine but first page response
                                  cached: @escaping (UsersPage) -> Void,
                                  completion: @escaping (Result<UsersPage, Error>) -> Void) -> Cancellable? {

        let requestDTO = UsersRequestDTO(since: since, per_page: per_page)
        let task = RepositoryTask()

        cache.getResponse(for: requestDTO) { result in

            if case let .success(responseDTO?) = result {
                cached(responseDTO.toDomain())
            }
            guard !task.isCancelled else { return }
            
            // if first page then

            let endpoint = APIEndpoints.getUsers(with: requestDTO)
            task.networkTask = self.dataTransferService.requestAll(with: endpoint, completion: { result in
                switch result {
                case .success(let responseDTOs):
                    let users = responseDTOs.map {
                        UsersPageResponseDTO.UserDTO.init(login: $0.login,
                                                          id: $0.id,
                                                          profileImage: UsersPageResponseDTO.UserDTO.ProfileImageDTO.init(imageUrl: $0.avatar_url, image: nil, invertedImage: nil),
                                                          type: $0.type,
                                                          note: nil,
                                                          following: nil,
                                                          followers: nil,
                                                          company: nil,
                                                          blog: nil) }
                    let usersPageResponseDTO = UsersPageResponseDTO.init(since: requestDTO.since, per_page: users.count, users: users)
                    let usersRequestDTO = UsersRequestDTO.init(since: since, per_page: users.count)
                    self.cache.save(response: usersPageResponseDTO, for:usersRequestDTO)
                    completion(.success(usersPageResponseDTO.toDomain()))
                    
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

        let requestDTO = LoadUsersWithUsernameAndNoteKeywordRequestDTO(query: query)
        let task = RepositoryTask()

        cache.searchUsersWithUsernameAndNoteKeyword(for: requestDTO) { result in

            if case let .success(responseDTO?) = result {
                completion(.success(responseDTO.toDomain()))
            }
            
            switch result {
            case .success(let usersPageResponseDTO):
                if let dto = usersPageResponseDTO {
                    completion(.success(dto.toDomain()))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }
    
    func fetchUserDetails(query: UserDetailsQuery,
                          cached: @escaping (User) -> Void,
                          completion: @escaping (Result<User, Error>) -> Void) -> Cancellable? {
        let requestDTO = UserDetailsRequestDTO(username: query.username)
        let task = RepositoryTask()

        cache.getUserDetailsResponse(for: requestDTO) { result in

            if case let .success(responseDTO?) = result {
                cached(responseDTO.toDomain())
            }
            guard !task.isCancelled else { return }

            let endpoint = APIEndpoints.getUserDetails(with: requestDTO)
            task.networkTask = self.dataTransferService.request(with: endpoint, completion: { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let responseDTO):
                    strongSelf.cache.updateUser(response: responseDTO, for: requestDTO)
                    completion(.success(responseDTO.toDomain()))
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        }
        return task
    }
}
