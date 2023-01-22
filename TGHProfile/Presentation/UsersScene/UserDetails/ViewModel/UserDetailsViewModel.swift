//
//  UserDetailsViewModel.swift
//  ExampleMVVM
//
//  Created by T0366-ADE-MB-1 on 19/12/2022.
//

import Foundation

protocol UserDetailsViewModelInput {
    func updatePosterImage(width: Int)
}

protocol UserDetailsViewModelOutput {
    var title: String { get }
    var posterImage: Observable<Data?> { get }
    var isPosterImageHidden: Bool { get }
    var overview: String { get }
}

protocol UserDetailsViewModel: UserDetailsViewModelInput, UserDetailsViewModelOutput { }

final class DefaultUserDetailsViewModel: UserDetailsViewModel {
    
    private let posterImagePath: String?
    private let posterImagesRepository: PosterImagesRepository
    private var imageLoadTask: Cancellable? { willSet { imageLoadTask?.cancel() } }

    // MARK: - OUTPUT
    let title: String
    let posterImage: Observable<Data?> = Observable(nil)
    let isPosterImageHidden: Bool
    let overview: String
    
    init(user: User,
         posterImagesRepository: PosterImagesRepository) {
        self.title = user.avatar_url ?? ""
        self.overview = user.avatar_url ?? ""
        self.posterImagePath = user.avatar_url
        self.isPosterImageHidden = user.id == nil
        self.posterImagesRepository = posterImagesRepository
    }
}

// MARK: - INPUT. View event methods
extension DefaultUserDetailsViewModel {
    
    func updatePosterImage(width: Int) {
        guard let posterImagePath = posterImagePath else { return }

        imageLoadTask = posterImagesRepository.fetchImage(with: posterImagePath, width: width) { result in
            guard self.posterImagePath == posterImagePath else { return }
            switch result {
            case .success(let data):
//                self.posterImage.value = data
                break
            case .failure: break
            }
            self.imageLoadTask = nil
        }
    }
}
