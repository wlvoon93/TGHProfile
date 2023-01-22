//
//  SaveUserNoteUseCase.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 07/01/2023.
//

import Foundation

import Foundation

protocol SaveUserNoteUseCase {
    func execute(requestValue: SaveUserNoteUseCaseRequestValue,
                 completion: @escaping (VoidResult) -> Void) -> Cancellable?
}

final class DefaultSaveUserNoteUseCase: SaveUserNoteUseCase {

    private let userNoteRepository: UserNoteRepository

    init(userNoteRepository: UserNoteRepository) {

        self.userNoteRepository = userNoteRepository
    }

    func execute(requestValue: SaveUserNoteUseCaseRequestValue, completion: @escaping (VoidResult) -> Void) -> Cancellable? {

        return userNoteRepository.saveUserNoteResponse(userId: requestValue.userId, note: requestValue.note) { result in
            completion(result)
        }
    }
}

struct SaveUserNoteUseCaseRequestValue {
    let userId: Int
    let note: String
}
