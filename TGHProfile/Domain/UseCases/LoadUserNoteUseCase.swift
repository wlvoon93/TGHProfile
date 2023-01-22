//
//  LoadUserNoteUseCase.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 08/01/2023.
//

import Foundation

protocol LoadUserNoteUseCase {
    func execute(requestValue: LoadUserNoteUseCaseRequestValue, completion: @escaping (Result<Note?, Error>) -> Void) -> Cancellable?
}

final class DefaultLoadUserNoteUseCase: LoadUserNoteUseCase {

    private let userNoteRepository: UserNoteRepository

    init(userNoteRepository: UserNoteRepository) {

        self.userNoteRepository = userNoteRepository
    }

    func execute(requestValue: LoadUserNoteUseCaseRequestValue, completion: @escaping (Result<Note?, Error>) -> Void) -> Cancellable? {

        return userNoteRepository.loadUserNoteResponse(userId: requestValue.userId, completion: completion)
    }
}

struct LoadUserNoteUseCaseRequestValue {
    let userId: Int
}
