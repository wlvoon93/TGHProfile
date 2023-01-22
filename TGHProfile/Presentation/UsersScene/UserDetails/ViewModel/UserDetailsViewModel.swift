//
//  UserDetailsViewModel.swift
//  ExampleMVVM
//
//  Created by T0366-ADE-MB-1 on 19/12/2022.
//

import Foundation
import UIKit

typealias UserDetailsViewModelDidSelectAction = (User) -> Void
typealias UserDetailsViewModelDidSaveNoteAction = (Note) -> Void

protocol UserDetailsViewModelInput {
    func viewWillAppear()
    func didTapSave(noteString: String, completion: @escaping (() -> Void))
}

protocol UserDetailsViewModelOutput {
    var username: Observable<String> { get }
    var profileImageUrl: Observable<String?> { get }
    var profileImageData: Observable<Data?> { get }
    var followers: Observable<Int> { get }
    var following: Observable<Int> { get }
    var company: Observable<String> { get }
    var blog: Observable<String> { get }
    var note: Observable<String> { get }
    var error: Observable<String> { get }
}

protocol UserDetailsViewModel: UserDetailsViewModelInput, UserDetailsViewModelOutput { }

final class DefaultUserDetailsViewModel: UserDetailsViewModel {
    
    let userId: Observable<Int?> = Observable(nil)
    let username: Observable<String> = Observable("")
    let profileImageUrl: Observable<String?> = Observable(nil)
    let profileImageData: Observable<Data?> = Observable(nil)
    let followers: Observable<Int> = Observable(0)
    let following: Observable<Int> = Observable(0)
    let company: Observable<String> = Observable("")
    let blog: Observable<String> = Observable("")
    let type: Observable<String> = Observable("")
    let note: Observable<String> = Observable("")
    
    private let loadUserDetailsUseCase: LoadUserDetailsUseCase
    private let saveUserNoteUseCase: SaveUserNoteUseCase
    private var profileImagesRepository: ProfileImagesRepository?
    
    private let didSaveNote: UserDetailsViewModelDidSaveNoteAction?
    
    private var userDetailsLoadTask: Cancellable? { willSet { userDetailsLoadTask?.cancel() } }
    private var userNoteSaveTask: Cancellable? { willSet { userNoteSaveTask?.cancel() } }
    private var imageLoadTask: Cancellable? { willSet { imageLoadTask?.cancel() } }
    let error: Observable<String> = Observable("")

    // MARK: - OUTPUT
    
    // MARK: - Init
    init(username: String,
         loadUserDetailsUseCase: LoadUserDetailsUseCase,
         saveUserNoteUseCase: SaveUserNoteUseCase,
         profileImagesRepository: ProfileImagesRepository,
         didSaveNote: UserDetailsViewModelDidSaveNoteAction? = nil) {
        self.username.value = username
        self.loadUserDetailsUseCase = loadUserDetailsUseCase
        self.saveUserNoteUseCase = saveUserNoteUseCase
        self.profileImagesRepository = profileImagesRepository
        self.didSaveNote = didSaveNote
    }
    
    // MARK: - Private
    private func updateUserDetails(user: User) {
        self.blog.value = user.blog ?? ""
        self.company.value = user.company ?? ""
        self.following.value = user.following ?? 0
        self.followers.value = user.followers ?? 0
        self.userId.value = user.userId
        self.profileImageData.value = user.profileImage?.image
        self.profileImageUrl.value = user.profileImage?.imageUrl
        
        self.updateProfileImage(width: 10)
    }
    
    private func loadUserDetails() {

        userDetailsLoadTask = loadUserDetailsUseCase.execute(
            requestValue: .init(username: username.value), cached: { user in
                self.updateUserDetails(user: user)
            },
            completion: { result in
                switch result {
                    case .success(let user):
                        self.updateUserDetails(user: user)
                    case .failure(let error):
                        self.handle(error: error)
                }
            }
        )
    }
    
    private func updateUserNote(noteString: String, completion: @escaping (() -> Void)) {
        if let userId = self.userId.value {
            userNoteSaveTask = saveUserNoteUseCase.execute(requestValue: .init(userId: userId, note: noteString), completion: { result in
                switch result {
                    case .success:
                        if let didSaveNote = self.didSaveNote {
                            didSaveNote(.init(note: noteString, userId: userId))
                        }
                        completion()
                    case .failure(let error):
                        self.handle(error: error)
                }
            })
        }
    }
    
    private func handle(error: Error) {
        self.error.value = error.isInternetConnectionError ?
            NSLocalizedString("No internet connection", comment: "") :
            NSLocalizedString("Failed loading users", comment: "")
    }
}

// MARK: - INPUT. View event methods
extension DefaultUserDetailsViewModel {
    func viewWillAppear() {
//        updateMoviesQueries()
        loadUserDetails()
    }
    
    func didTapSave(noteString: String, completion: @escaping () -> Void) {
        updateUserNote(noteString: noteString, completion: completion)
    }
    
//    func viewDidLoad() {
//        loadUserDetails()
//    }
    
    func updateProfileImage(width: Int) {
        guard let profileImagePath = self.profileImageUrl.value else { return }
        
        _ = profileImagesRepository?.fetchImage(with: profileImagePath, width: width) { [weak self] result in
            guard let self = self else { return }
            if case let .success(data) = result {
                self.profileImageData.value = data
            }
        }
        
    }
}
