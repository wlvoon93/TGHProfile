//
//  UserDetailsViewModel.swift
//  ExampleMVVM
//
//  Created by T0366-ADE-MB-1 on 19/12/2022.
//

import Foundation

protocol UserDetailsViewModelInput {
    func updateProfileImage(width: Int)
}

protocol UserDetailsViewModelOutput {
    var title: String { get }
    var profileImage: Observable<Data?> { get }
    var isProfileImageHidden: Bool { get }
    var overview: String { get }
}

protocol UserDetailsViewModel: UserDetailsViewModelInput, UserDetailsViewModelOutput { }

final class DefaultUserDetailsViewModel: UserDetailsViewModel {
    
    private let profileImagePath: String?
    private let profileImagesRepository: ProfileImagesRepository
    private var imageLoadTask: Cancellable? { willSet { imageLoadTask?.cancel() } }

    // MARK: - OUTPUT
    let title: String
    let profileImage: Observable<Data?> = Observable(nil)
    let isProfileImageHidden: Bool
    let overview: String
    
    init(user: User,
         profileImagesRepository: ProfileImagesRepository) {
        self.title = user.avatar_url ?? ""
        self.overview = user.avatar_url ?? ""
        self.profileImagePath = user.avatar_url
        self.isProfileImageHidden = user.id == nil
        self.profileImagesRepository = profileImagesRepository
    }
}

// MARK: - INPUT. View event methods
extension DefaultUserDetailsViewModel {
    
    func updateProfileImage(width: Int) {
        guard let profileImagePath = profileImagePath else { return }

        imageLoadTask = profileImagesRepository.fetchImage(with: profileImagePath, width: width) { result in
            guard self.profileImagePath == profileImagePath else { return }
            switch result {
            case .success(let data):
//                self.profileImage.value = data
                break
            case .failure: break
            }
            self.imageLoadTask = nil
        }
    }
}
