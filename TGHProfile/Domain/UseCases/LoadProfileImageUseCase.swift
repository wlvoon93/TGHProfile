//
//  LoadProfileImageUseCase.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 18/01/2023.
//

import Foundation

protocol LoadProfileImageUseCase {
    func execute(requestValue: LoadProfileImageUseCaseRequestValue,
                 cached: @escaping (ProfileImage) -> Void,
                 completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable?
}

final class DefaultLoadProfileImageUseCase: LoadProfileImageUseCase {

    private let profileImagesRepository: ProfileImagesRepository

    init(profileImagesRepository: ProfileImagesRepository) {

        self.profileImagesRepository = profileImagesRepository
    }

    func execute(requestValue: LoadProfileImageUseCaseRequestValue,
                 cached: @escaping (ProfileImage) -> Void,
                 completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable? {
        
        return profileImagesRepository.fetchImage(for: requestValue.userId, imagePath: requestValue.imageUrl, cached: cached, completion: completion)
    }
}

struct LoadProfileImageUseCaseRequestValue {
    let userId: Int
    let imageUrl: String
}
