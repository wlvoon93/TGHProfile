//
//  SaveUserNoteUseCaseTests.swift
//  TGHProfileTests
//
//  Created by T0366-ADE-MB-1 on 11/01/2023.
//

import Foundation
import XCTest
@testable import TGHProfile

class SaveUserNoteUseCaseTests: XCTestCase {
    struct UserNoteRepositoryMock: UserNoteRepository {
        func loadUserNoteResponse(userId: Int, completion: @escaping (Result<Note?, Error>) -> Void) -> Cancellable? {
            return nil
        }
        
        func loadUsersNoteResponse(userIds: [Int], completion: @escaping (Result<[Note], Error>) -> Void) -> Cancellable? {
            return nil
        }
        
        var saveUserNoteResponseResult: VoidResult
        func saveUserNoteResponse(userId: Int, note: String, completion: @escaping (VoidResult) -> Void) -> Cancellable? {
            completion(saveUserNoteResponseResult)
            return nil
        }
    }
    
    enum UserNoteRepositorySuccessTestError: Error {
        case failedFetching
    }
    
    func testSaveUserNoteUseCase_whenSuccessfullySaveUserNote() {
        // given
        let expectation = self.expectation(description: "Notes saved")
        expectation.expectedFulfillmentCount = 1
        let useCase = DefaultSaveUserNoteUseCase(userNoteRepository: UserNoteRepositoryMock(saveUserNoteResponseResult: .success))

        // when
        let requestValue = SaveUserNoteUseCaseRequestValue(userId: 22, note: "Some note")
        _ = useCase.execute(requestValue: requestValue, completion: { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                return
            }
        })
        
        // then
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSaveUserNoteUseCase_whenFailedSaveUserNote() {
        // given
        let expectation = self.expectation(description: "Notes not saved")
        expectation.expectedFulfillmentCount = 1
        let useCase = DefaultSaveUserNoteUseCase(userNoteRepository: UserNoteRepositoryMock(saveUserNoteResponseResult: .failure(UserNoteRepositorySuccessTestError.failedFetching)))

        // when
        let requestValue = SaveUserNoteUseCaseRequestValue(userId: 20, note: "Some note")
        _ = useCase.execute(requestValue: requestValue, completion: { result in
            switch result {
            case .success:
                return
            case .failure:
                expectation.fulfill()
            }
        })
        
        // then
        waitForExpectations(timeout: 1, handler: nil)
    }
    
}
