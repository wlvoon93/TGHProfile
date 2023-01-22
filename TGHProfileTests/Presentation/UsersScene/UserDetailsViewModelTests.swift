//
//  UserDetailsViewModelTests.swift
//  TGHProfileTests
//
//  Created by T0366-ADE-MB-1 on 18/01/2023.
//

import XCTest
@testable import TGHProfile

class UsersDetailsViewModelTests: XCTestCase {
    
    private enum SearchMoviesUseCaseError: Error {
        case someError
    }
    
    // since and per page might be wrong
    let userDetails: User = User.stub(login: "Albert Liew", id: 0, avatar_url: "https://avatars.githubusercontent.com/u/25", type: "normal", note: Note(note: "left a note", userId: 0))
    
    let note1: Note = Note.stub(note: "left a note", userId: 0)
    
    class LoadUserDetailsUseCaseMock: LoadUserDetailsUseCase {
        
        var expectation: XCTestExpectation?
        var error: Error?
        var user = User.init(login: nil, userId: nil, profileImage: nil, type: nil, following: nil, followers: nil, company: nil, blog: nil)
        
        func execute(requestValue: LoadUserDetailsUseCaseRequestValue, cached: @escaping (User) -> Void, completion: @escaping (Result<User, Error>) -> Void) -> Cancellable? {
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(user))
            }
            expectation?.fulfill()
            return nil
        }
    }
    
    class SaveUserNoteUseCaseMock: SaveUserNoteUseCase {
        var expectation: XCTestExpectation?
        var error: Error?
        var user = User.init(login: nil, userId: nil, profileImage: nil, type: nil, following: nil, followers: nil, company: nil, blog: nil)
        
        func execute(requestValue: SaveUserNoteUseCaseRequestValue, completion: @escaping (VoidResult) -> Void) -> Cancellable? {
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success)
            }
            expectation?.fulfill()
            return nil
        }
    }
    
    class LoadProfileImageUseCaseMock: LoadProfileImageUseCase {
        
        var expectation: XCTestExpectation?
        var error: Error?
        
        func execute(requestValue: LoadProfileImageUseCaseRequestValue,
                     cached: @escaping (ProfileImage) -> Void,
                     completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable? {
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(Data()))
            }
            expectation?.fulfill()
            return nil
        }
    }
    
    func test_whenLoadUserDetailsUseCaseRetrievesUserDetails_thenLoadSuccess() {
        // given
        let loadUserDetailsUseCaseMock = LoadUserDetailsUseCaseMock()
        loadUserDetailsUseCaseMock.expectation = self.expectation(description: "load user details success")
        loadUserDetailsUseCaseMock.user = userDetails
        let saveUserNoteUseCaseMock = SaveUserNoteUseCaseMock()
        let loadProfileImageUseCaseMock = LoadProfileImageUseCaseMock()
        
        let viewModel = DefaultUserDetailsViewModel(username: "Albert Liew", note: "left a note", loadUserDetailsUseCase: loadUserDetailsUseCaseMock, saveUserNoteUseCase: saveUserNoteUseCaseMock, loadProfileImageUseCase: loadProfileImageUseCaseMock, didSaveNote: nil)
        // when
        // the current did search might not be accurate
        viewModel.load()
        
        
        
        // then
        waitForExpectations(timeout: 1, handler: nil)
    }
    
}
