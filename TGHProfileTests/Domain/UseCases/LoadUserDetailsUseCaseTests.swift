//
//  LoadUserDetailsUseCaseTests.swift
//  TGHProfileTests
//
//  Created by T0366-ADE-MB-1 on 11/01/2023.
//

import Foundation
import XCTest
@testable import TGHProfile

class LoadUserDetailsUseCaseTests: XCTestCase {
    static let user: User = {
        return User.stub(login: "Jimmy", id: 0, avatar_url: "https://avatars.githubusercontent.com/u/22", type: "normal", note: Note(note: "Choo is the way", userId: 0))
    }()
    
    enum UsersRepositorySuccessTestError: Error {
        case failedFetching
    }
    
    struct UsersRepositoryMock: UsersRepository {
        
        func searchUsersList(query: String, completion: @escaping (Result<UsersPage, Error>) -> Void) -> Cancellable? {
            return nil
        }
        
        var fetchUserDetailsResult: Result<User, Error>
        func fetchUserDetails(query: UserDetailsQuery, completion: @escaping (Result<User, Error>) -> Void) -> Cancellable? {
            completion(fetchUserDetailsResult)
            return nil
        }
        
        func fetchAllUsersList(since: Int, per_page: Int?, cached: @escaping (UsersPage) -> Void, completion: @escaping (Result<UsersPage, Error>) -> Void) -> Cancellable? {
            return nil
        }
    }
    
    func testSearchUsersUseCase_whenSuccessfullyFetchUserDetails() {
        // given
        let expectation = self.expectation(description: "Loaded single user details")
        expectation.expectedFulfillmentCount = 1
        let useCase = DefaultLoadUserDetailsUseCase(usersRepository: UsersRepositoryMock(fetchUserDetailsResult: .success(LoadUserDetailsUseCaseTests.user)))

        // when
        var completedUser: User? = nil
        let requestValue = LoadUserDetailsUseCaseRequestValue(username: "Jimmy")
        _ = useCase.execute(requestValue: requestValue, completion: { result in
            switch result {
            case .success(let user):
                completedUser = user
                expectation.fulfill()
            case .failure:
                return
            }
        })
        
        // then
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(completedUser?.login == "Jimmy")
    }
    
    func testSearchUsersUseCase_whenFailedFetchUserDetails() {
        // given
        let expectation = self.expectation(description: "Loaded single user details")
        expectation.expectedFulfillmentCount = 1
        let useCase = DefaultLoadUserDetailsUseCase(usersRepository: UsersRepositoryMock(fetchUserDetailsResult: .failure(UsersRepositorySuccessTestError.failedFetching)))

        // when
        var completedUser: User? = nil
        let requestValue = LoadUserDetailsUseCaseRequestValue(username: "Jimmy")
        _ = useCase.execute(requestValue: requestValue, completion: { result in
            switch result {
            case .success(let user):
                completedUser = user
            case .failure:
                expectation.fulfill()
            }
        })
        
        // then
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(completedUser == nil)
    }
    
}
