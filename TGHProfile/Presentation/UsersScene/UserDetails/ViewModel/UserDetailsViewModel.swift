//
//  UserDetailsViewModel.swift
//  ExampleMVVM
//
//  Created by T0366-ADE-MB-1 on 19/12/2022.
//

import Foundation
import UIKit
import Combine

typealias UserDetailsViewModelDidSelectAction = (User) -> Void
typealias UserDetailsViewModelDidSaveNoteAction = (Note) -> Void

protocol UserDetailsViewModelInput {
    func viewWillAppear()
    func didTapSave(noteString: String, completion: @escaping (() -> Void))
}

protocol UserDetailsViewModelOutput {
    var username: CurrentValueSubject<String, Never> { get }
    var profileImageUrl: CurrentValueSubject<String?, Never> { get }
    var profileImageData: CurrentValueSubject<Data?, Never> { get }
    var followers: CurrentValueSubject<Int, Never> { get }
    var following: CurrentValueSubject<Int, Never> { get }
    var company: CurrentValueSubject<String, Never> { get }
    var blog: CurrentValueSubject<String, Never> { get }
    var note: CurrentValueSubject<String, Never> { get }
    var error: CurrentValueSubject<String, Never> { get }
}

protocol UserDetailsViewModel: UserDetailsViewModelInput, UserDetailsViewModelOutput { }

final class DefaultUserDetailsViewModel: UserDetailsViewModel {
    
    let userId = CurrentValueSubject<Int?, Never>(nil)
    let username = CurrentValueSubject<String, Never>("")
    let profileImageUrl = CurrentValueSubject<String?, Never>(nil)
    let profileImageData = CurrentValueSubject<Data?, Never>(nil)
    let followers = CurrentValueSubject<Int, Never>(0)
    let following = CurrentValueSubject<Int, Never>(0)
    let company = CurrentValueSubject<String, Never>("")
    let blog = CurrentValueSubject<String, Never>("")
    let type = CurrentValueSubject<String, Never>("")
    let note = CurrentValueSubject<String, Never>("")
    
    private let loadUserDetailsUseCase: LoadUserDetailsUseCase
    private let saveUserNoteUseCase: SaveUserNoteUseCase
    private let loadProfileImageUseCase: LoadProfileImageUseCase
    
    private let didSaveNote: UserDetailsViewModelDidSaveNoteAction?
    
    private var userDetailsLoadTask: Cancellable? { willSet { userDetailsLoadTask?.cancel() } }
    private var userNoteSaveTask: Cancellable? { willSet { userNoteSaveTask?.cancel() } }
    private var imageLoadTask: Cancellable? { willSet { imageLoadTask?.cancel() } }
    let error = CurrentValueSubject<String, Never>("")

    // MARK: - OUTPUT
    
    // MARK: - Init
    init(username: String,
         note: String,
         loadUserDetailsUseCase: LoadUserDetailsUseCase,
         saveUserNoteUseCase: SaveUserNoteUseCase,
         loadProfileImageUseCase: LoadProfileImageUseCase,
         didSaveNote: UserDetailsViewModelDidSaveNoteAction? = nil) {
        self.username.value = username
        self.loadUserDetailsUseCase = loadUserDetailsUseCase
        self.saveUserNoteUseCase = saveUserNoteUseCase
        self.loadProfileImageUseCase = loadProfileImageUseCase
        self.didSaveNote = didSaveNote
        self.note.value = note
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
        
        self.updateProfileImage()
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
        loadUserDetails()
    }
    
    func load() {
        loadUserDetails()
    }
    
    func didTapSave(noteString: String, completion: @escaping () -> Void) {
        updateUserNote(noteString: noteString, completion: completion)
    }
    
    func updateProfileImage() {
        guard let profileImagePath = self.profileImageUrl.value else { return }
        
        if let userId = self.userId.value {
            _ = loadProfileImageUseCase.execute(requestValue: .init(userId: userId, imageUrl: profileImagePath), cached: {_ in
                
            }, completion: {[weak self] result in
                guard let self = self else { return }
                if case let .success(data) = result {
                    self.profileImageData.value = data
                }
            })
        }
    }
}
