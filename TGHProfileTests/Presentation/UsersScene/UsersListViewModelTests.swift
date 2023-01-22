//
//  UsersListViewModelTests.swift
//  TGHProfileTests
//
//  Created by T0366-ADE-MB-1 on 14/01/2023.
//

import XCTest
@testable import TGHProfile

class UsersListViewModelTests: XCTestCase {
    
    private enum SearchMoviesUseCaseError: Error {
        case someError
    }
    
    // since and per page might be wrong
    let usersPages: [UsersPage] = {
        let page1 = UsersPage(since: 0, per_page: 3, users: [
            User.stub(login: "Albert Liew", id: 0, avatar_url: "https://avatars.githubusercontent.com/u/25", type: "normal", note: Note(note: "left a note", userId: 0)),
            User.stub(login: "Albert Lim", id: 1, avatar_url: "https://avatars.githubusercontent.com/u/18", type: "normal", note: Note(note: "He is wicked", userId: 1)),
            User.stub(login: "Albert Tan", id: 2, avatar_url: "https://avatars.githubusercontent.com/u/22", type: "normal", note: Note(note: "Choo is the way", userId: 2))
        ])
        let page2 = UsersPage(since: 3, per_page: 3, users: [
            User.stub(login: "Ron Lee", id: 3, avatar_url: "https://avatars.githubusercontent.com/u/31", type: "normal", note: Note(note: "Here is where I create ", userId: 3)),
            User.stub(login: "Ron Law", id: 4, avatar_url: "https://avatars.githubusercontent.com/u/32", type: "normal", note: Note(note: "add it to the StackViewController", userId: 4)),
            User.stub(login: "Ron Tee", id: 5, avatar_url: "https://avatars.githubusercontent.com/u/33", type: "normal", note: Note(note: " am trying to create a statistics", userId: 5))
        ])
        let page3 = UsersPage(since: 6, per_page: 3, users: [
            User.stub(login: "Raymond Lim", id: 6, avatar_url: "https://avatars.githubusercontent.com/u/41", type: "normal", note: Note(note: "added to the main ", userId: 6)),
            User.stub(login: "Raymond Yaw", id: 7, avatar_url: "https://avatars.githubusercontent.com/u/42", type: "normal", note: Note(note: "allowing me to scroll", userId: 7)),
            User.stub(login: "Raymond Lam", id: 8, avatar_url: "https://avatars.githubusercontent.com/u/43", type: "normal", note: Note(note: "it just stacks them", userId: 8))
        ])
        return [page1, page2]
    }()
    
    let notes1: [Note] = {
        return [
            Note.stub(note: "left a note", userId: 0),
            Note.stub(note: "He is wicked", userId: 1),
            Note.stub(note: "Choo is the way", userId: 2)
        ]
    }()
    
    let notes2: [Note] = {
        return [
            Note.stub(note: "left a note", userId: 0),
            Note.stub(note: "He is wicked", userId: 1),
            Note.stub(note: "Choo is the way", userId: 2),
            Note.stub(note: "Here is where I create ", userId: 3),
            Note.stub(note: "add it to the StackViewController", userId: 4),
            Note.stub(note: " am trying to create a statistics", userId: 5)
        ]
    }()
    
    class ListAllUsersUseCaseMock: ListAllUsersUseCase {
        var expectation: XCTestExpectation?
        var error: Error?
        var page = UsersPage(since: 0, per_page: 0, users: [])

        func execute(requestValue: ListAllUsersUseCaseRequestValue,
                     cached: @escaping (UsersPage) -> Void,
                     completion: @escaping (Result<UsersPage, Error>) -> Void) -> Cancellable? {
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(page))
            }
            expectation?.fulfill()
            return nil
        }
    }
    
    class SearchUsersUseCaseMock: SearchUsersUseCase {
        var expectation: XCTestExpectation?
        var error: Error?
        var page = UsersPage(since: 0, per_page: 0, users: [])

        func execute(requestValue: SearchUsersUseCaseRequestValue,
                     completion: @escaping (Result<UsersPage, Error>) -> Void) -> Cancellable? {
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(page))
            }
            expectation?.fulfill()
            return nil
        }
    }
    
    class LoadUserNoteUseCaseMock: LoadUserNoteUseCase {
        var expectation: XCTestExpectation?
        var error: Error?
        var note = Note(note: nil, userId: 0)

        func execute(requestValue: LoadUserNoteUseCaseRequestValue,
                     completion: @escaping (Result<Note?, Error>) -> Void) -> Cancellable? {
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(note))
            }
            expectation?.fulfill()
            return nil
        }
    }
    
    class LoadUsersNoteUseCaseMock: LoadUsersNoteUseCase {
        var expectation: XCTestExpectation?
        var error: Error?
        var notes: [Note] = []

        func execute(requestValue: LoadUsersNoteUseCaseRequestValue,
                     completion: @escaping (Result<[Note], Error>) -> Void) -> Cancellable? {
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(notes))
            }
            expectation?.fulfill()
            return nil
        }
    }
    
    func test_whenListUsersUseCaseRetrievesFirstPage_thenViewModelContainsOnlyFirstPage() {
        // given
        let listUsersUseCaseMock = ListAllUsersUseCaseMock()
        listUsersUseCaseMock.expectation = self.expectation(description: "contains only first page")
        listUsersUseCaseMock.page = UsersPage(since: 0, per_page: 3, users: usersPages[0].users)
        let searchUsersUseCaseMock = SearchUsersUseCaseMock()
        searchUsersUseCaseMock.page = UsersPage(since: 0, per_page: 3, users: [
            User.stub(login: "Albert Liew", id: 0, avatar_url: "https://avatars.githubusercontent.com/u/25", type: "normal", note: Note(note: "left a note", userId: 0))])
        let loadUserNoteUseCaseMock = LoadUserNoteUseCaseMock()
        loadUserNoteUseCaseMock.note = Note.stub(note: "left a note", userId: 0)
        let loadUsersNoteUseCaseMock = LoadUsersNoteUseCaseMock()
        loadUsersNoteUseCaseMock.expectation = self.expectation(description: "load notes for users")
        loadUsersNoteUseCaseMock.notes = notes1
        let viewModel = DefaultUsersListViewModel(searchUsersUseCase: searchUsersUseCaseMock,
                                                  listAllUsersUseCase: listUsersUseCaseMock,
                                                  loadUserNoteUseCase: loadUserNoteUseCaseMock,
                                                  loadUsersNoteUseCase: loadUsersNoteUseCaseMock)
        // when
        // the current did search might not be accurate
        viewModel.didLoadFirstPage()
        
        // then
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(viewModel.pages.count, 1) // page start with 0
        XCTAssertEqual(viewModel.items.value.count, 3)
    }
    
    func test_whenListUsersUseCaseRetrievesFirstAndSecondPage_thenViewModelContainsTwoPages() {
        // given
        let listUsersUseCaseMock = ListAllUsersUseCaseMock()
        listUsersUseCaseMock.expectation = self.expectation(description: "load first page users")
        listUsersUseCaseMock.page = UsersPage(since: 0, per_page: 3, users: usersPages[0].users)
        let searchUsersUseCaseMock = SearchUsersUseCaseMock()
        searchUsersUseCaseMock.page = UsersPage(since: 0, per_page: 3, users: [
            User.stub(login: "Albert Liew", id: 0, avatar_url: "https://avatars.githubusercontent.com/u/25", type: "normal", note: Note(note: "left a note", userId: 0))])
        let loadUserNoteUseCaseMock = LoadUserNoteUseCaseMock()
        loadUserNoteUseCaseMock.note = Note.stub(note: "left a note", userId: 0)
        let loadUsersNoteUseCaseMock = LoadUsersNoteUseCaseMock()
        loadUsersNoteUseCaseMock.expectation = self.expectation(description: "load notes for 1 page users")
        loadUsersNoteUseCaseMock.notes = notes1
        let viewModel = DefaultUsersListViewModel(searchUsersUseCase: searchUsersUseCaseMock,
                                                  listAllUsersUseCase: listUsersUseCaseMock,
                                                  loadUserNoteUseCase: loadUserNoteUseCaseMock,
                                                  loadUsersNoteUseCase: loadUsersNoteUseCaseMock)
        
        // when
        viewModel.didLoadFirstPage()
        waitForExpectations(timeout: 1, handler: nil)
        
        listUsersUseCaseMock.expectation = self.expectation(description: "load second page users")
        listUsersUseCaseMock.page = UsersPage(since: 3, per_page: 3, users: usersPages[1].users)
        loadUsersNoteUseCaseMock.expectation = self.expectation(description: "load notes for 2 pages users")
        loadUsersNoteUseCaseMock.notes = notes1
        
        viewModel.didLoadNextPage()
        
        // then
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(viewModel.pages.count, 2) // page start with 0
        XCTAssertEqual(viewModel.items.value.count, 6)
    }
   
    func test_whenSearchUsersUseCaseRetrievesOnePage_thenViewModelContainsOnePages() {
        // given
        let listUsersUseCaseMock = ListAllUsersUseCaseMock()
        listUsersUseCaseMock.page = UsersPage(since: 0, per_page: 3, users: usersPages[0].users)
        let searchUsersUseCaseMock = SearchUsersUseCaseMock()
        searchUsersUseCaseMock.expectation = self.expectation(description: "search users in one page")
        searchUsersUseCaseMock.page = UsersPage(since: 0, per_page: 3, users: [
            User.stub(login: "Albert Liew", id: 0, avatar_url: "https://avatars.githubusercontent.com/u/25", type: "normal", note: Note(note: "left a note", userId: 0))])
        let loadUserNoteUseCaseMock = LoadUserNoteUseCaseMock()
        loadUserNoteUseCaseMock.note = Note.stub(note: "left a note", userId: 0)
        let loadUsersNoteUseCaseMock = LoadUsersNoteUseCaseMock()
        loadUsersNoteUseCaseMock.notes = notes1
        let viewModel = DefaultUsersListViewModel(searchUsersUseCase: searchUsersUseCaseMock,
                                                  listAllUsersUseCase: listUsersUseCaseMock,
                                                  loadUserNoteUseCase: loadUserNoteUseCaseMock,
                                                  loadUsersNoteUseCase: loadUsersNoteUseCaseMock)
        
        // when
        viewModel.didSearch(query: "Albert")
        
        // then
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(viewModel.searchPage.count, 1)
        XCTAssertEqual(viewModel.searchItems.value.count, 1)
    }
}
