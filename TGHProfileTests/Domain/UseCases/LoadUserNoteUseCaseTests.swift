//
//  LoadUserNoteUseCaseTests.swift
//  TGHProfileTests
//
//  Created by T0366-ADE-MB-1 on 12/01/2023.
//

import Foundation
import XCTest
@testable import TGHProfile

class LoadUserNoteUseCaseTests: XCTestCase {
    static let note: Note = {
        return Note(note: "Choo is the way", userId: 20)
    }()
    struct UserNoteRepositoryMock: UserNoteRepository {
        var loadUserNoteResponseResult: Result<Note?, Error>
        func loadUserNoteResponse(userId: Int, completion: @escaping (Result<Note?, Error>) -> Void) -> Cancellable? {
            completion(loadUserNoteResponseResult)
            return nil
        }
        
        func loadUsersNoteResponse(userIds: [Int], completion: @escaping (Result<[Note], Error>) -> Void) -> Cancellable? {
            return nil
        }
        
        func saveUserNoteResponse(userId: Int, note: String, completion: @escaping (VoidResult) -> Void) -> Cancellable? {
            return nil
        }
    }
    
    enum UserNoteRepositorySuccessTestError: Error {
        case failedFetching
    }
    
    func testLoadUserNoteUseCase_whenSuccessfullyLoadUserNote() {
        // given
        let expectation = self.expectation(description: "Note loaded")
        expectation.expectedFulfillmentCount = 1
        let useCase = DefaultLoadUserNoteUseCase(userNoteRepository: UserNoteRepositoryMock(loadUserNoteResponseResult: .success(LoadUserNoteUseCaseTests.note)))

        // when
        var completedNote: Note? = nil
        let requestValue = LoadUserNoteUseCaseRequestValue(userId: 22)
        _ = useCase.execute(requestValue: requestValue, completion: { result in
            switch result {
            case .success(let note):
                completedNote = note
                expectation.fulfill()
            case .failure:
                return
            }
        })
        
        // then
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(completedNote?.note == LoadUserNoteUseCaseTests.note.note)
    }
    
    func testLoadUserNoteUseCase_whenFailedSaveUserNote() {
        // given
        let expectation = self.expectation(description: "Note not loaded")
        expectation.expectedFulfillmentCount = 1
        let useCase = DefaultLoadUserNoteUseCase(userNoteRepository: UserNoteRepositoryMock(loadUserNoteResponseResult: .failure(UserNoteRepositorySuccessTestError.failedFetching)))

        // when
        var completedNote: Note? = nil
        let requestValue = LoadUserNoteUseCaseRequestValue(userId: 22)
        _ = useCase.execute(requestValue: requestValue, completion: { result in
            switch result {
            case .success(let note):
                completedNote = note
            case .failure:
                expectation.fulfill()
            }
        })
        
        // then
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(completedNote?.note == nil)
    } 
}
