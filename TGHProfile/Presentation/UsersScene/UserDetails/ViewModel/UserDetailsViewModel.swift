//
//  UserDetailsViewModel.swift
//  ExampleMVVM
//
//  Created by T0366-ADE-MB-1 on 19/12/2022.
//

import Foundation

typealias UserDetailsViewModelDidSelectAction = (User) -> Void
typealias UserDetailsViewModelDidSaveNoteAction = (Note) -> Void

protocol UserDetailsViewModelInput {
    func viewWillAppear()
    func didTapSave(noteString: String, completion: @escaping (() -> Void))
}

protocol UserDetailsViewModelOutput {
    var username: Observable<String> { get }
    var avatarUrl: Observable<String> { get }
    var followers: Observable<Int> { get }
    var following: Observable<Int> { get }
    var company: Observable<String> { get }
    var blog: Observable<String> { get }
    var note: Observable<String> { get }
    var error: Observable<String> { get }
//    var profileImage: Observable<Data?> { get }
//    var isProfileImageHidden: Bool { get }
//    var overview: String { get }
}

protocol UserDetailsViewModel: UserDetailsViewModelInput, UserDetailsViewModelOutput { }

final class DefaultUserDetailsViewModel: UserDetailsViewModel {
    
    let userId: Observable<Int?> = Observable(nil)
    let username: Observable<String> = Observable("")
    let avatarUrl: Observable<String> = Observable("")
    let followers: Observable<Int> = Observable(0)
    let following: Observable<Int> = Observable(0)
    let company: Observable<String> = Observable("")
    let blog: Observable<String> = Observable("")
    let type: Observable<String> = Observable("")
    let note: Observable<String> = Observable("")
    
    //    private let profileImagePath: String?
//    private let profileImagesRepository: ProfileImagesRepository
//    private var imageLoadTask: Cancellable? { willSet { imageLoadTask?.cancel() } }
    private let loadUserDetailsUseCase: LoadUserDetailsUseCase
    private let saveUserNoteUseCase: SaveUserNoteUseCase
    
    private let didSaveNote: UserDetailsViewModelDidSaveNoteAction?
    
    private var userDetailsLoadTask: Cancellable? { willSet { userDetailsLoadTask?.cancel() } }
    private var userNoteSaveTask: Cancellable? { willSet { userNoteSaveTask?.cancel() } }
    let error: Observable<String> = Observable("")

    // MARK: - OUTPUT
//    let title: String
//    let profileImage: Observable<Data?> = Observable(nil)
//    let isProfileImageHidden: Bool
//    let overview: String.
    
    // MARK: - Init
    init(username: String,
         loadUserDetailsUseCase: LoadUserDetailsUseCase,
         saveUserNoteUseCase: SaveUserNoteUseCase,
         didSaveNote: UserDetailsViewModelDidSaveNoteAction? = nil) {
//        self.title = user.avatar_url ?? ""
//        self.overview = user.avatar_url ?? ""
//        self.profileImagePath = user.avatar_url
//        self.isProfileImageHidden = user.id == nil
//        self.profileImagesRepository = profileImagesRepository
//        self.didSelect = didSelect
        self.username.value = username
        self.loadUserDetailsUseCase = loadUserDetailsUseCase
        self.saveUserNoteUseCase = saveUserNoteUseCase
        self.didSaveNote = didSaveNote
    }
    
    // MARK: - Private
    private func updateUserDetails(user: User) {
        self.avatarUrl.value = user.avatar_url ?? ""
        self.blog.value = user.blog ?? ""
        self.company.value = user.company ?? ""
        self.following.value = user.following ?? 0
        self.followers.value = user.followers ?? 0
        self.userId.value = user.id
    }
    
    private func loadUserDetails() {

        userDetailsLoadTask = loadUserDetailsUseCase.execute(
            requestValue: .init(username: username.value),
            completion: { result in
                switch result {
                    case .success(let user):
                        self.updateUserDetails(user: user)
                    case .failure(let error):
                        self.handle(error: error)
                }
        })
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
//        guard let profileImagePath = profileImagePath else { return }
//
//        imageLoadTask = profileImagesRepository.fetchImage(with: profileImagePath, width: width) { result in
//            guard self.profileImagePath == profileImagePath else { return }
//            switch result {
//            case .success(let data):
////                self.profileImage.value = data
//                break
//            case .failure: break
//            }
//            self.imageLoadTask = nil
//        }
    }
}
