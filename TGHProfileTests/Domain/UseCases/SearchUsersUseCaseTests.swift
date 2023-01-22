//
//  SearchUsersUseCaseTests.swift
//  TGHProfileTests
//
//  Created by T0366-ADE-MB-1 on 11/01/2023.
//

import Foundation
import XCTest
@testable import TGHProfile

class SearchUsersUseCaseTests: XCTestCase {
    static let usersPages: [UsersPage] = {
        let page1 = UsersPage(since: 0, per_page: 3, users: [
            User.stub(login: "Albert Liew", id: 0, avatar_url: "https://avatars.githubusercontent.com/u/25", type: "normal", note: Note(note: "left a note", userId: 0)),
            User.stub(login: "Albert Lim", id: 0, avatar_url: "https://avatars.githubusercontent.com/u/18", type: "normal", note: Note(note: "He is wicked", userId: 0)),
            User.stub(login: "Albert Tan", id: 0, avatar_url: "https://avatars.githubusercontent.com/u/22", type: "normal", note: Note(note: "Choo is the way", userId: 0))
        ])
        
        return [page1]
    }()
    
    enum UsersRepositorySuccessTestError: Error {
        case failedFetching
    }
    
    struct UsersRepositoryMock: UsersRepository {
        
        var searchUsersListResult: Result<UsersPage, Error>
        func searchUsersList(query: String, completion: @escaping (Result<UsersPage, Error>) -> Void) -> Cancellable? {
            completion(searchUsersListResult)
            return nil
        }
        
        func fetchUserDetails(query: UserDetailsQuery, cached: @escaping (User) -> Void, completion: @escaping (Result<User, Error>) -> Void) -> Cancellable? {
            return nil
        }
        
        func fetchAllUsersList(since: Int, per_page: Int?, cached: @escaping (UsersPage) -> Void, completion: @escaping (Result<UsersPage, Error>) -> Void) -> Cancellable? {
            return nil
        }
    }
    
    func testSearchUsersUseCase_whenSuccessfullySearchUsers() {
        // given
        let expectation = self.expectation(description: "Users found")
        expectation.expectedFulfillmentCount = 1
        let useCase = DefaultSearchUsersUseCase(usersRepository: UsersRepositoryMock(searchUsersListResult: .success(SearchUsersUseCaseTests.usersPages[0])))

        // when
        var completedPage: UsersPage? = nil
        let requestValue = SearchUsersUseCaseRequestValue(query: "Albert")
        _ = useCase.execute(requestValue: requestValue, completion: { result in
            switch result {
            case .success(let page):
                completedPage = page
                expectation.fulfill()
            case .failure:
                return
            }
        })
        
        // then
        waitForExpectations(timeout: 1, handler: nil)
        guard let unwrappedLogin = try? XCTUnwrap(completedPage?.users.first?.login) else {
            XCTFail("Unwrapping of unwrappedLogin failed")
            return
        }

        XCTAssertTrue(unwrappedLogin.contains(requestValue.query))
    }
    
    func testSearchUsersUseCase_whenFailedSearchUsers() {
        // given
        let expectation = self.expectation(description: "Users found")
        expectation.expectedFulfillmentCount = 1
        let useCase = DefaultSearchUsersUseCase(usersRepository: UsersRepositoryMock(searchUsersListResult: .failure(UsersRepositorySuccessTestError.failedFetching)))

        // when
        var completedPage: UsersPage? = nil
        let requestValue = SearchUsersUseCaseRequestValue(query: "Albert")
        _ = useCase.execute(requestValue: requestValue, completion: { result in
            switch result {
            case .success(let page):
                completedPage = page
            case .failure:
                expectation.fulfill()
            }
        })
        
        // then
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(completedPage == nil)
    }
    
}
