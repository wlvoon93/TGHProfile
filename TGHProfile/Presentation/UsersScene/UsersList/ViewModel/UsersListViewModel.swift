//
//  UsersListViewModel.swift
//  ExampleMVVM
//
//  Created by T0366-ADE-MB-1 on 15/12/2022.
//

import Foundation
import SwiftUI

struct UsersListViewModelActions {
    let showUserDetails: (String, @escaping (_ didSelect: Note) -> Void) -> Void
}

enum TableMode {
    case listAll
    case search
}

enum UsersListViewModelLoading {
    case fullScreen
    case nextPage
}

protocol UsersListViewModelInput {
    func viewDidLoad()
    func didLoadNextPage()
    func didSearch(query: String)
    func didCancelSearch()
    func didSelectItem(at index: Int)
}

protocol UsersListViewModelOutput {
    var items: Observable<[BaseItemViewModel]> { get } /// Also we can calculate view model items on demand:  https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/pull/10/files
    var searchItems: Observable<[BaseItemViewModel]> { get }
    var tableMode: Observable<TableMode> { get }
    var loading: Observable<UsersListViewModelLoading?> { get }
    var query: Observable<String> { get }
    var error: Observable<String> { get }
    var isEmpty: Bool { get }
    var screenTitle: String { get }
    var emptyDataTitle: String { get }
    var errorTitle: String { get }
    var searchBarPlaceholder: String { get }
}

protocol UsersListViewModel: UsersListViewModelInput, UsersListViewModelOutput {}

final class DefaultUsersListViewModel: UsersListViewModel {

    private let listAllUsersUseCase: ListAllUsersUseCase
    private let searchUsersUseCase: SearchUsersUseCase
    private let loadUserNoteUseCase: LoadUserNoteUseCase
    private let loadUsersNoteUseCase: LoadUsersNoteUseCase
    
    private let actions: UsersListViewModelActions?

    var since: Int = 0 // page start with 0
    var perPage: Int = 0
    var totalPageCount: Int = 1
    var nextSince: Int { since+perPage }

    private(set) var pages: [UsersPage] = []
    private var usersLoadTask: Cancellable? { willSet { usersLoadTask?.cancel() } }
    private var noteLoadTask: Cancellable? { willSet { usersLoadTask?.cancel() } }
    private var multipleNoteLoadTask: Cancellable? { willSet { multipleNoteLoadTask?.cancel() } }

    // MARK: - OUTPUT

    let items: Observable<[BaseItemViewModel]> = Observable([])
    let searchItems: Observable<[BaseItemViewModel]> = Observable([])
    let tableMode: Observable<TableMode> = Observable(.listAll)
    let loading: Observable<UsersListViewModelLoading?> = Observable(.none)
    let query: Observable<String> = Observable("")
    let error: Observable<String> = Observable("")
    var isEmpty: Bool { return items.value.isEmpty }
    let screenTitle = NSLocalizedString("Users", comment: "")
    let emptyDataTitle = NSLocalizedString("No Data", comment: "")
    let errorTitle = NSLocalizedString("Error", comment: "")
    let searchBarPlaceholder = NSLocalizedString("Search Users", comment: "")

    // MARK: - Init

    init(searchUsersUseCase: SearchUsersUseCase,
         listAllUsersUseCase: ListAllUsersUseCase,
         loadUserNoteUseCase: LoadUserNoteUseCase,
         loadUsersNoteUseCase: LoadUsersNoteUseCase,
         actions: UsersListViewModelActions? = nil) {
        self.searchUsersUseCase = searchUsersUseCase
        self.listAllUsersUseCase = listAllUsersUseCase
        self.loadUserNoteUseCase = loadUserNoteUseCase
        self.loadUsersNoteUseCase = loadUsersNoteUseCase
        self.actions = actions
    }

    // MARK: - Private

    private func appendPage(_ usersPage: UsersPage) {
        
        perPage = usersPage.users.count
        since = nextSince
        
        let userIDs = usersPage.users.compactMap { $0.userId }
        multipleNoteLoadTask = loadUsersNoteUseCase.execute(requestValue: .init(userIds: userIDs)) { result in
            
            var usersWithNote: [User] = []
            
            switch result {
            case .success(let notes):
                
                for user in usersPage.users {
                    let userNote = notes.filter {
                        return $0.userId == user.userId
                    }
                    
                    var userWithNote: User? = nil
                    if !userNote.isEmpty {
                        userWithNote = User.init(login: user.login, userId: user.userId, profileImage: user.profileImage, type: user.type, note: userNote.first, following: user.following, followers: user.followers, company: user.company, blog: user.blog)
                    }
                    usersWithNote.append(userWithNote ?? user)
                }
                
            case .failure(let error):
                self.handle(error: error)
                return
            }
            
            let usersPageWithNote = UsersPage.init(since: usersPage.since, per_page: usersPage.per_page, users: usersWithNote)

            self.pages = self.pages
                .filter { $0.since != usersPageWithNote.since }
                + [usersPageWithNote]

            var userListItems: [BaseItemViewModel] = []
            for (_, page) in self.pages.enumerated() {
                for (userIndex, user) in page.users.enumerated() {
                    let isFourthItem = (userListItems.count) % 4 == 3 && userIndex != 0
                    let hasNote = user.note != nil && user.note?.note != "" && user.note?.note != nil
                    if isFourthItem && hasNote {
                        userListItems.append(UserListAvatarColourInvertedAndNoteItemViewModel.init(user: user))
                    } else if isFourthItem {
                        userListItems.append(UserListAvatarColourInvertedItemViewModel.init(user: user))
                    } else if hasNote {
                        userListItems.append(UserListNoteItemViewModel.init(user: user))
                    } else {
                        userListItems.append(UsersListItemViewModel.init(user: user))
                    }
                }
            }
            self.handleAppendAsyncReturnResult(result: .success(userListItems))
            let userIDsTest = userListItems.compactMap { $0.user.userId }
            let userIdSet: Set = Set(userIDsTest)
            
            var array: [Int] = []
            for item in userListItems {
                if let id = item.user.userId{
                    if array.contains(id) {
                        print("\(id) is already exist")
                    } else {
                        array.append(id)
                    }
                }
            }
            if userListItems.count != userIdSet.count {
    
            }
        }
    }
    
    // for search user list page
    private func setSearchUserPage(_ usersPage: UsersPage) {
        
        let userIDs = usersPage.users.compactMap { $0.userId }
        multipleNoteLoadTask = loadUsersNoteUseCase.execute(requestValue: .init(userIds: userIDs)) { result in
            
            var usersWithNote: [User] = []
            
            switch result {
            case .success(let notes):
                
                for user in usersPage.users {
                    let userNote = notes.filter {
                        return $0.userId == user.userId
                    }
                    
                    var userWithNote: User? = nil
                    if !userNote.isEmpty {
                        userWithNote = User.init(login: user.login, userId: user.userId, profileImage: user.profileImage, type: user.type, note: userNote.first, following: user.following, followers: user.followers, company: user.company, blog: user.blog)
                    }
                    usersWithNote.append(userWithNote ?? user)
                }
                
            case .failure(let error):
                self.handle(error: error)
                return
            }
            
            let usersPageWithNote = UsersPage.init(since: usersPage.since, per_page: usersPage.per_page, users: usersWithNote)

            self.pages = self.pages
                .filter { $0.since != usersPageWithNote.since }
                + [usersPageWithNote]

            var userListItems: [BaseItemViewModel] = []
            for (_, page) in self.pages.enumerated() {
                for (userIndex, user) in page.users.enumerated() {
                    let isFourthItem = (userListItems.count) % 4 == 3 && userIndex != 0
                    let hasNote = user.note != nil && user.note?.note != "" && user.note?.note != nil
                    if isFourthItem && hasNote {
                        userListItems.append(UserListAvatarColourInvertedAndNoteItemViewModel.init(user: user))
                    } else if isFourthItem {
                        userListItems.append(UserListAvatarColourInvertedItemViewModel.init(user: user))
                    } else if hasNote {
                        userListItems.append(UserListNoteItemViewModel.init(user: user))
                    } else {
                        userListItems.append(UsersListItemViewModel.init(user: user))
                    }
                }
            }
            
            self.searchItems.value = userListItems
        }
    }

    private func resetPages() {
        since = 0
        totalPageCount = 1
        pages.removeAll()
        items.value.removeAll()
    }
    
    private func loadAllUsers(pageQuery: ListAllUsersUseCaseRequestValue, loading: UsersListViewModelLoading) {
        self.loading.value = loading

        usersLoadTask = listAllUsersUseCase.execute(
            requestValue: pageQuery,
            cached: appendPage,
            completion: { result in
                switch result {
                case .success(let page):
                    self.perPage = page.users.count
                    self.appendPage(page)
                    self.loading.value = .none
                case .failure(let error):
                    self.handle(error: error)
                    self.loading.value = .none
                }
        })
    }
    
    
    private func handleAppendAsyncReturnResult(result: Result<[BaseItemViewModel], Error>){
        switch result {
        case .success(let vms):
            self.items.value = vms
            self.loading.value = .none
        case .failure(let error):
            self.handle(error: error)
        }
        self.loading.value = .none
    }

    private func load(userQuery: UserQuery, loading: UsersListViewModelLoading) {
        self.loading.value = loading
        query.value = userQuery.query

        usersLoadTask = searchUsersUseCase.execute(
            requestValue: .init(query: userQuery.query),
            completion: { result in
                switch result {
                case .success(let page):
                    self.resetPages()
                    self.appendPage(page)
                    return 
                case .failure(let error):
                    self.handle(error: error)
                }
                self.loading.value = .none
        })
    }

    private func handle(error: Error) {
        self.error.value = error.isInternetConnectionError ?
            NSLocalizedString("No internet connection", comment: "") :
            NSLocalizedString("Failed loading users", comment: "")
    }

    private func loadFirstPage() {
        resetPages()
        loadAllUsers(pageQuery: ListAllUsersUseCaseRequestValue.init(since: 0, perPage: nil), loading: .nextPage)
    }
}

// MARK: - INPUT. View event methods

extension DefaultUsersListViewModel {

    func viewDidLoad() {
        loadFirstPage()
    }

    func didLoadNextPage() {
        guard loading.value == .none else { return }
        loadAllUsers(pageQuery: ListAllUsersUseCaseRequestValue.init(since: nextSince, perPage: perPage), loading: .nextPage)
    }

    func didSearch(query: String) {
        guard !query.isEmpty else { return }
    }
    
    func didloadFirstPage() {
        loadFirstPage()
    }

    func didCancelSearch() {
        usersLoadTask?.cancel()
    }

    func didSelectItem(at index: Int) {
        actions?.showUserDetails(pages.users[index].login ?? "") { note in
            if let pageSize = self.pages.first?.users.count {
                let page = Int(Float(index / pageSize).rounded(.up))
                self.pages[page] = UsersPage.init(since: self.pages[page].since, per_page: self.pages[page].per_page, users: self.pages[page].users.map {
                    if $0.userId == note.userId {
                        return User.init(login: $0.login, userId: $0.userId, profileImage: .init(imageUrl: $0.profileImage?.imageUrl, image: $0.profileImage?.image, invertedImage: $0.profileImage?.invertedImage), type: $0.type, note: note, following: $0.following, followers: $0.followers, company: $0.company, blog: $0.blog)
                    }
                    return $0
                })
            }
        }
                                 
    }
}

// MARK: - Private

private extension Array where Element == UsersPage {
    var users: [User] { flatMap { $0.users } }
}
