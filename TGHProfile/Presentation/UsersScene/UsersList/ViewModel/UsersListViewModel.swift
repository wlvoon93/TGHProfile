//
//  UsersListViewModel.swift
//  ExampleMVVM
//
//  Created by T0366-ADE-MB-1 on 15/12/2022.
//

import Foundation
import SwiftUI
import Combine

struct UsersListViewModelActions {
    let showUserDetails: (String, String, @escaping (_ didSelect: Note) -> Void) -> Void
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
    func didSelectSearchItem(at index: Int)
    func didLoadFirstPage()
    func handleReachabilityNoInternet()
    func resetSearchPages()
}

protocol UsersListViewModelOutput {
    var items: CurrentValueSubject<[UserListTVCVMDisplayable], Never> { get } /// Also we can calculate view model items on demand:  https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/pull/10/files
    var searchItems: CurrentValueSubject<[UserListTVCVMDisplayable], Never> { get }
    var tableMode: CurrentValueSubject<TableMode, Never> { get }
    var loading: CurrentValueSubject<UsersListViewModelLoading?, Never> { get }
    var query: CurrentValueSubject<String, Never> { get }
    var error: CurrentValueSubject<String, Never> { get }
    var isEmpty: Bool { get }
    var isSearchEmpty: Bool { get }
    var isConnected: Bool { get set }
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
    var isConnected = true

    private(set) var pages: [UsersPage] = []
    private(set) var searchPage: [UsersPage] = []
    private var usersLoadTask: Cancellable? { willSet { usersLoadTask?.cancel() } }
    private var noteLoadTask: Cancellable? { willSet { usersLoadTask?.cancel() } }
    private var multipleNoteLoadTask: Cancellable? { willSet { multipleNoteLoadTask?.cancel() } }

    // MARK: - OUTPUT

    let items = CurrentValueSubject<[UserListTVCVMDisplayable], Never>([])
    let searchItems = CurrentValueSubject<[UserListTVCVMDisplayable], Never>([])
    let tableMode = CurrentValueSubject<TableMode, Never>(.listAll)
    let loading = CurrentValueSubject<UsersListViewModelLoading?, Never>(.none)
    let query = CurrentValueSubject<String, Never>("")
    let error = CurrentValueSubject<String, Never>("")
    var isEmpty: Bool { return items.value.isEmpty }
    var isSearchEmpty: Bool { return searchItems.value.isEmpty }
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

    // MARK: - Private - All Users List
    private func appendPage(_ usersPage: UsersPage) {
        
        perPage = usersPage.users.count
        
        let userIDs = usersPage.users.compactMap { $0.userId }
        multipleNoteLoadTask = loadUsersNoteUseCase.execute(requestValue: .init(userIds: userIDs)) { [weak self] result in
            
            guard let strongSelf = self else { return }
            
            var usersWithNote: [User] = []
            
            switch result {
            case .success(let notes):
                
                // add notes to the users
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
                strongSelf.handle(error: error)
                return
            }
            
            let usersPageWithNote = UsersPage.init(since: usersPage.since, per_page: usersPage.per_page, users: usersWithNote)

            strongSelf.pages = strongSelf.pages
                .filter { $0.since != usersPageWithNote.since }
                + [usersPageWithNote]

            var userListItems: [UserListTVCVMDisplayable] = []
            
            for (_, page) in strongSelf.pages.enumerated() {
                for (userIndex, user) in page.users.enumerated() {
                    // append different kind of cell view models
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
            
            strongSelf.handleAppendAsyncReturnResult(result: .success(userListItems))
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
            completion: { [weak self] result in
                
                guard let strongSelf = self else { return }
                
                switch result {
                case .success(let page):
                    strongSelf.perPage = page.users.count
                    strongSelf.appendPage(page)
                    strongSelf.loading.value = .none
                case .failure(let error):
                    strongSelf.handle(error: error)
                    strongSelf.loading.value = .none
                }
        })
    }
    
    private func handleAppendAsyncReturnResult(result: Result<[UserListTVCVMDisplayable], Error>){
        switch result {
        case .success(let vms):
            self.items.value = vms
            self.loading.value = .none
        case .failure(let error):
            self.handle(error: error)
        }
        self.loading.value = .none
    }
    
    private func loadFirstPage() {
        resetPages()
        loadAllUsers(pageQuery: ListAllUsersUseCaseRequestValue.init(since: 0, perPage: nil), loading: .nextPage)
    }
    
    // MARK: - Private - Search Users List
    private func setSearchUserPage(_ usersPage: UsersPage) {
        
        let userIDs = usersPage.users.compactMap { $0.userId }
        multipleNoteLoadTask = loadUsersNoteUseCase.execute(requestValue: .init(userIds: userIDs)) { [weak self] result in
            guard let strongSelf = self else { return }
            
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
                strongSelf.handle(error: error)
                return
            }
            
            let usersPageWithNote = UsersPage.init(since: usersPage.since, per_page: usersPage.per_page, users: usersWithNote)

            strongSelf.searchPage = strongSelf.searchPage
                .filter { $0.since != usersPageWithNote.since }
                + [usersPageWithNote]

            var userListItems: [UserListTVCVMDisplayable] = []
            for (_, page) in strongSelf.searchPage.enumerated() {
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
            
            strongSelf.searchItems.value = userListItems
        }
    }

    internal func resetSearchPages() {
        searchPage.removeAll()
        searchItems.value.removeAll()
    }

    private func searchUser(userQuery: UserQuery, loading: UsersListViewModelLoading) {
        self.loading.value = loading
        query.value = userQuery.query

        usersLoadTask = searchUsersUseCase.execute(
            requestValue: .init(query: userQuery.query),
            completion: { [weak self] result in
                
                guard let strongSelf = self else { return }
                
                switch result {
                case .success(let page):
                    strongSelf.resetSearchPages()
                    strongSelf.setSearchUserPage(page)
                case .failure(let error):
                    strongSelf.handle(error: error)
                }
                strongSelf.loading.value = .none
        })
    }
    
    private func getNextSince() -> Int {
        return items.value.last?.user.userId ?? 0
    }

    // MARK: - Private - General
    private func handle(error: Error) {
        if !isConnected {
            self.error.value = error.isInternetConnectionError ?
                NSLocalizedString("No internet connection", comment: "") :
                NSLocalizedString("Failed loading users", comment: "")
        }
    }
}

// MARK: - INPUT. View event methods

extension DefaultUsersListViewModel {
    
    func handleReachabilityNoInternet() {
        self.error.value = NSLocalizedString("No internet connection", comment: "")
    }

    func viewDidLoad() {
        loadFirstPage()
    }

    func didLoadNextPage() {
        guard loading.value == .none else { return }
        loadAllUsers(pageQuery: ListAllUsersUseCaseRequestValue.init(since: getNextSince(), perPage: perPage), loading: .nextPage)
    }

    func didSearch(query: String) {
        guard !query.isEmpty else { return }
        searchUser(userQuery: .init(query: query), loading: .fullScreen)
    }
    
    func didLoadFirstPage() {
        loadFirstPage()
    }

    func didCancelSearch() {
        usersLoadTask?.cancel()
    }

    func didSelectItem(at index: Int) {
        actions?.showUserDetails(self.items.value[index].user.login ?? "", self.items.value[index].user.note?.note ?? "") { [weak self] note in
            
            guard let strongSelf = self else { return }
            
            let isFourthItem = (strongSelf.items.value.count) % 4 == 3 && index != 0
            if let noteString = note.note, noteString.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                
                if let searchItemIndex = strongSelf.searchItems.value.indices.filter({ return strongSelf.searchItems.value[$0].user.userId == note.userId }).first {
                    strongSelf.searchItems.value[searchItemIndex].user.note = note
                    strongSelf.searchItems.value[searchItemIndex] = isFourthItem ? UserListAvatarColourInvertedAndNoteItemViewModel.init(user: strongSelf.searchItems.value[searchItemIndex].user) : UserListNoteItemViewModel.init(user: strongSelf.searchItems.value[searchItemIndex].user)
                }
                
                if let itemIndex = strongSelf.items.value.indices.filter({ return strongSelf.items.value[$0].user.userId == note.userId }).first {
                    strongSelf.items.value[itemIndex].user.note = note
                    strongSelf.items.value[itemIndex] = isFourthItem ? UserListAvatarColourInvertedAndNoteItemViewModel.init(user: strongSelf.items.value[itemIndex].user) : UserListNoteItemViewModel.init(user: strongSelf.items.value[itemIndex].user)
                }
                
            } else {
                
                if let searchItemIndex = strongSelf.searchItems.value.indices.filter({ return strongSelf.searchItems.value[$0].user.userId == note.userId }).first {
                    strongSelf.searchItems.value[searchItemIndex].user.note = note
                    strongSelf.searchItems.value[searchItemIndex] = isFourthItem ? UserListAvatarColourInvertedItemViewModel.init(user: strongSelf.searchItems.value[searchItemIndex].user) : UsersListItemViewModel.init(user: strongSelf.searchItems.value[searchItemIndex].user)
                }
                
                if let itemIndex = strongSelf.items.value.indices.filter({ return strongSelf.items.value[$0].user.userId == note.userId }).first {
                    strongSelf.items.value[itemIndex].user.note = note
                    strongSelf.items.value[itemIndex] = isFourthItem ? UserListAvatarColourInvertedItemViewModel.init(user: strongSelf.items.value[itemIndex].user) : UsersListItemViewModel.init(user: strongSelf.items.value[itemIndex].user)
                }
            }
        }
    }
    
    func didSelectSearchItem(at index: Int) {
        actions?.showUserDetails(self.searchItems.value[index].user.login ?? "", self.searchItems.value[index].user.note?.note ?? "") { [weak self] note in
            
            guard let strongSelf = self else { return }
            
            let isFourthItem = (strongSelf.searchItems.value.count) % 4 == 3 && index != 0
            if let noteString = note.note, noteString.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                
                if let searchItemIndex = strongSelf.searchItems.value.indices.filter({ return strongSelf.searchItems.value[$0].user.userId == note.userId }).first {
                    strongSelf.searchItems.value[searchItemIndex].user.note = note
                    strongSelf.searchItems.value[searchItemIndex] = isFourthItem ? UserListAvatarColourInvertedAndNoteItemViewModel.init(user: strongSelf.searchItems.value[searchItemIndex].user) : UserListNoteItemViewModel.init(user: strongSelf.searchItems.value[searchItemIndex].user)
                }
                
                if let itemIndex = strongSelf.items.value.indices.filter({ return strongSelf.items.value[$0].user.userId == note.userId }).first {
                    strongSelf.items.value[itemIndex].user.note = note
                    strongSelf.items.value[itemIndex] = isFourthItem ? UserListAvatarColourInvertedAndNoteItemViewModel.init(user: strongSelf.items.value[itemIndex].user) : UserListNoteItemViewModel.init(user: strongSelf.items.value[itemIndex].user)
                }
                
            } else {
                
                if let searchItemIndex = strongSelf.searchItems.value.indices.filter({ return strongSelf.searchItems.value[$0].user.userId == note.userId }).first {
                    strongSelf.searchItems.value[searchItemIndex].user.note = note
                    strongSelf.searchItems.value[searchItemIndex] = isFourthItem ? UserListAvatarColourInvertedItemViewModel.init(user: strongSelf.searchItems.value[searchItemIndex].user) : UsersListItemViewModel.init(user: strongSelf.searchItems.value[searchItemIndex].user)
                }
                
                if let itemIndex = strongSelf.items.value.indices.filter({ return strongSelf.items.value[$0].user.userId == note.userId }).first {
                    strongSelf.items.value[itemIndex].user.note = note
                    strongSelf.items.value[itemIndex] = isFourthItem ? UserListAvatarColourInvertedItemViewModel.init(user: strongSelf.items.value[itemIndex].user) : UsersListItemViewModel.init(user: strongSelf.items.value[itemIndex].user)
                }
            }
        }
    }
}

// MARK: - Private

private extension Array where Element == UsersPage {
    var users: [User] { flatMap { $0.users } }
}
