//
//  ListAllUsersUseCaseTests.swift
//  TGHProfileTests
//
//  Created by T0366-ADE-MB-1 on 11/01/2023.
//

import Foundation
import XCTest
@testable import TGHProfile

class ListAllUsersUseCaseTests: XCTestCase {
    static let usersPages: [UsersPage] = {
        let page1 = UsersPage(since: 0, per_page: 3, users: [
            User.stub(login: "Micheal", id: 0, avatar_url: "https://avatars.githubusercontent.com/u/25", type: "normal", note: Note(note: "left a note", userId: 0)),
            User.stub(login: "John", id: 0, avatar_url: "https://avatars.githubusercontent.com/u/18", type: "normal", note: Note(note: "He is wicked", userId: 0)),
            User.stub(login: "Jimmy", id: 0, avatar_url: "https://avatars.githubusercontent.com/u/22", type: "normal", note: Note(note: "Choo is the way", userId: 0))
        ])
        
        let page2 = UsersPage(since: 3, per_page: 3, users: [
            User.stub(login: "James", id: 0, avatar_url: "https://avatars.githubusercontent.com/u/27", type: "normal", note: Note(note: "Name is bond", userId: 0)),
            User.stub(login: "Albert", id: 0, avatar_url: "https://avatars.githubusercontent.com/u/21", type: "normal", note: Note(note: "coming Friday", userId: 0)),
            User.stub(login: "Leon", id: 0, avatar_url: "https://avatars.githubusercontent.com/u/19", type: "normal", note: Note(note: "Khoo tin lok", userId: 0))
        ])
        
        return [page1, page2]
    }()
    
    enum UsersRepositorySuccessTestError: Error {
        case failedFetching
    }
    
    struct UsersRepositoryMock: UsersRepository {
        
        var page: UsersPage? = nil
        
        func searchUsersList(query: String, completion: @escaping (Result<UsersPage, Error>) -> Void) -> Cancellable? {
            return nil
        }
        
        func fetchUserDetails(query: UserDetailsQuery, completion: @escaping (Result<User, Error>) -> Void) -> Cancellable? {
            return nil
        }
        
        var fetchAllUsersListResult: Result<UsersPage, Error>
        func fetchAllUsersList(since: Int, per_page: Int?, cached: @escaping (UsersPage) -> Void, completion: @escaping (Result<UsersPage, Error>) -> Void) -> Cancellable? {
            
            completion(fetchAllUsersListResult)
            return nil
        }
    }
    
    func testFetchAllUsersUseCase_whenSuccessfullyFetchesAllUsers() {
        // given
        let expectation = self.expectation(description: "Users retrieved")
        expectation.expectedFulfillmentCount = 1
        let useCase = DefaultListAllUsersUseCase(usersRepository:
                                                    UsersRepositoryMock(fetchAllUsersListResult: .success(ListAllUsersUseCaseTests.usersPages[0])))

        // when
        var completedPage: UsersPage? = nil
        let requestValue = ListAllUsersUseCaseRequestValue(since: 0, perPage: nil)
        _ = useCase.execute(requestValue: requestValue, cached: { _ in }, completion: { result in
            switch result {
            case .success(let page):
                completedPage = page
                expectation.fulfill()
            case .failure:
                break
            }
            
        })
        
        // then
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(completedPage?.users.first?.login == ListAllUsersUseCaseTests.usersPages[0].users.first?.login)
    }
    
    func testFetchAllUsersUseCase_whenFailedFetchesAllUsers() {
        // given
        let expectation = self.expectation(description: "Users not retrieved")
        expectation.expectedFulfillmentCount = 1
        let useCase = DefaultListAllUsersUseCase(usersRepository:
                                                    UsersRepositoryMock(fetchAllUsersListResult: .failure(UsersRepositorySuccessTestError.failedFetching)))

        // when
        var completedPage: UsersPage? = nil
        let requestValue = ListAllUsersUseCaseRequestValue(since: 0, perPage: nil)
        _ = useCase.execute(requestValue: requestValue, cached: { _ in }, completion: { result in
            switch result {
            case .success(let page):
                completedPage = page
                
            case .failure:
                expectation.fulfill()
            }
            
        })
        
        // then
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertTrue(completedPage == nil)
    }
    
}
