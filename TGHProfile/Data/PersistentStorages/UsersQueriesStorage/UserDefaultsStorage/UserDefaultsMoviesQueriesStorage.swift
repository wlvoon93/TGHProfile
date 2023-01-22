//
//  UserDefaultsUsersQueriesStorage.swift
//  ExampleMVVM
//
//  Created by Oleh on 03.10.18.
//

import Foundation

final class UserDefaultsUsersQueriesStorage {
    private let maxStorageLimit: Int
    private let recentsUsersQueriesKey = "recentsUsersQueries"
    private var userDefaults: UserDefaults
    
    init(maxStorageLimit: Int, userDefaults: UserDefaults = UserDefaults.standard) {
        self.maxStorageLimit = maxStorageLimit
        self.userDefaults = userDefaults
    }

    private func fetchUsersQuries() -> [UserQuery] {
        if let queriesData = userDefaults.object(forKey: recentsUsersQueriesKey) as? Data {
            if let userQueryList = try? JSONDecoder().decode(UserQueriesListUDS.self, from: queriesData) {
                return userQueryList.list.map { $0.toDomain() }
            }
        }
        return []
    }

    private func persist(usersQuries: [UserQuery]) {
        let encoder = JSONEncoder()
        let userQueryUDSs = usersQuries.map(UserQueryUDS.init)
        if let encoded = try? encoder.encode(UserQueriesListUDS(list: userQueryUDSs)) {
            userDefaults.set(encoded, forKey: recentsUsersQueriesKey)
        }
    }
}

extension UserDefaultsUsersQueriesStorage: UsersQueriesStorage {

    func fetchRecentsQueries(maxCount: Int, completion: @escaping (Result<[UserQuery], Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            var queries = self.fetchUsersQuries()
            queries = queries.count < self.maxStorageLimit ? queries : Array(queries[0..<maxCount])
            completion(.success(queries))
        }
    }

    func saveRecentQuery(query: UserQuery, completion: @escaping (Result<UserQuery, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            var queries = self.fetchUsersQuries()
            self.cleanUpQueries(for: query, in: &queries)
            queries.insert(query, at: 0)
            self.persist(usersQuries: queries)

            completion(.success(query))
        }
    }
}


// MARK: - Private
extension UserDefaultsUsersQueriesStorage {

    private func cleanUpQueries(for query: UserQuery, in queries: inout [UserQuery]) {
        removeDuplicates(for: query, in: &queries)
        removeQueries(limit: maxStorageLimit - 1, in: &queries)
    }

    private func removeDuplicates(for query: UserQuery, in queries: inout [UserQuery]) {
        queries = queries.filter { $0 != query }
    }

    private func removeQueries(limit: Int, in queries: inout [UserQuery]) {
        queries = queries.count <= limit ? queries : Array(queries[0..<limit])
    }
}
