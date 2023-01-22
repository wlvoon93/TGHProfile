//
//  LoadUsersNoteUseCaseTests.swift
//  TGHProfileTests
//
//  Created by T0366-ADE-MB-1 on 13/01/2023.
//

import Foundation
import XCTest
@testable import TGHProfile

class LoadUsersNoteUseCaseTests: XCTestCase {
    static let notes: [Note] = {
        return [
            Note(note: "Choo is the way", userId: 11),
            Note(note: "New Note", userId: 12),
            Note(note: "Another Note", userId: 13),
        ]
    }()
    struct UsersNoteRepositoryMock: UserNoteRepository {
        
        func loadUserNoteResponse(userId: Int, completion: @escaping (Result<Note?, Error>) -> Void) -> Cancellable? {
            return nil
        }
        
        var loadUsersNoteResponseResult: Result<[Note], Error>
        func loadUsersNoteResponse(userIds: [Int], completion: @escaping (Result<[Note], Error>) -> Void) -> Cancellable? {
            completion(loadUsersNoteResponseResult)
            return nil
        }
        
        func saveUserNoteResponse(userId: Int, note: String, completion: @escaping (VoidResult) -> Void) -> Cancellable? {
            return nil
        }
    }
    
    enum UsersNoteRepositorySuccessTestError: Error {
        case failedFetching
    }
    
    func testLoadUsersNoteUseCase_whenSuccessfullyLoadUsersNote() {
        // given
        let expectation = self.expectation(description: "Notes loaded")
        expectation.expectedFulfillmentCount = 1
        let useCase = DefaultLoadUsersNoteUseCase(userNoteRepository: UsersNoteRepositoryMock(loadUsersNoteResponseResult: .success(LoadUsersNoteUseCaseTests.notes)))

        // when
        var completedNotes: [Note]? = nil
        let requestValue = LoadUsersNoteUseCaseRequestValue(userIds: [11, 12, 13])
        _ = useCase.execute(requestValue: requestValue, completion: { result in
            switch result {
            case .success(let notes):
                completedNotes = notes
                expectation.fulfill()
            case .failure:
                return
            }
        })
        
        // then
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(completedNotes?.first?.note == LoadUsersNoteUseCaseTests.notes[0].note)
    }
    
    func testLoadUsersNoteUseCase_whenFailedSaveUsersNote() {
        // given
        let expectation = self.expectation(description: "Notes not loaded")
        expectation.expectedFulfillmentCount = 1
        let useCase = DefaultLoadUsersNoteUseCase(userNoteRepository: UsersNoteRepositoryMock(loadUsersNoteResponseResult: .failure(UsersNoteRepositorySuccessTestError.failedFetching)))

        // when
        var completedNotes: [Note]? = nil
        let requestValue = LoadUsersNoteUseCaseRequestValue(userIds: [11, 12, 13])
        _ = useCase.execute(requestValue: requestValue, completion: { result in
            switch result {
            case .success(let notes):
                completedNotes = notes
            case .failure:
                expectation.fulfill()
            }
        })
        
        // then
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(completedNotes == nil)
    }
}
