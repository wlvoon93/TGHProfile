//
//  LoadUsersNoteUseCase.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 08/01/2023.
//

import Foundation

protocol LoadUsersNoteUseCase {
    func execute(requestValue: LoadUsersNoteUseCaseRequestValue, completion: @escaping (Result<[Note], Error>) -> Void) -> Cancellable?
}

final class DefaultLoadUsersNoteUseCase: LoadUsersNoteUseCase {

    private let userNoteRepository: UserNoteRepository

    init(userNoteRepository: UserNoteRepository) {

        self.userNoteRepository = userNoteRepository
    }

    func execute(requestValue: LoadUsersNoteUseCaseRequestValue, completion: @escaping (Result<[Note], Error>) -> Void) -> Cancellable? {

        return userNoteRepository.loadUsersNoteResponse(userIds: requestValue.userIds, completion: completion)
    }
}

struct LoadUsersNoteUseCaseRequestValue {
    let userIds: [Int]
}
