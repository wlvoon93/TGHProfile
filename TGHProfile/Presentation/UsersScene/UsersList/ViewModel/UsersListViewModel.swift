//
//  UsersListViewModel.swift
//  ExampleMVVM
//
//  Created by T0366-ADE-MB-1 on 15/12/2022.
//

import Foundation

struct UsersListViewModelActions {
    /// Note: if you would need to edit user inside Details screen and update this Users List screen with updated user then you would need this closure:
    /// showUserDetails: (User, @escaping (_ updated: User) -> Void) -> Void
//    let showUserDetails: (User) -> Void
    let showUserDetails: (String, @escaping (_ didSelect: Note) -> Void) -> Void
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
    var items: Observable<[UsersListItemViewModel]> { get } /// Also we can calculate view model items on demand:  https://github.com/kudoleh/iOS-Clean-Architecture-MVVM/pull/10/files
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

    var currentPage: Int = 0
    var totalPageCount: Int = 1
//    var hasMorePages: Bool { currentPage < totalPageCount }
    var nextPage: Int { currentPage + 1 }

    private var pages: [UsersPage] = []
    private var usersLoadTask: Cancellable? { willSet { usersLoadTask?.cancel() } }
    private var noteLoadTask: Cancellable? { willSet { usersLoadTask?.cancel() } }
    private var multipleNoteLoadTask: Cancellable? { willSet { multipleNoteLoadTask?.cancel() } }

    // MARK: - OUTPUT

    let items: Observable<[UsersListItemViewModel]> = Observable([])
    let loading: Observable<UsersListViewModelLoading?> = Observable(.none)
    let query: Observable<String> = Observable("")
    let error: Observable<String> = Observable("")
    var isEmpty: Bool { return items.value.isEmpty }
    let screenTitle = NSLocalizedString("Users", comment: "")
    let emptyDataTitle = NSLocalizedString("Search results", comment: "")
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
        currentPage = Int(Double((usersPage.since/usersPage.per_page)).rounded(.down))
//        totalPageCount = usersPage.totalPages
        
        let userIDs = usersPage.users.compactMap { $0.id }
        multipleNoteLoadTask = loadUsersNoteUseCase.execute(requestValue: .init(userIds: userIDs)) { result in
            
            var usersWithNote: [User] = []
            
            switch result {
            case .success(let notes):
                
                for user in usersPage.users {
                    let userNote = notes.filter {
                        return $0.userId == user.id
                    }
                    
                    var userWithNote: User? = nil
                    if !userNote.isEmpty {
                        userWithNote = User.init(login: user.login, id: user.id, avatar_url: user.avatar_url, type: user.type, note: userNote.first, following: user.following, followers: user.followers, company: user.company, blog: user.blog)
                    }
                    usersWithNote.append(userWithNote ?? user)
                }
                
                
            case .failure(let error):
                self.handle(error: error)
            }
            
            let usersPageWithNote = UsersPage.init(since: usersPage.since, per_page: usersPage.per_page, users: usersWithNote)

            self.pages = self.pages
                .filter { $0.since != usersPageWithNote.since }
                + [usersPageWithNote]

            self.items.value = self.pages.users.map(UsersListItemViewModel.init)
        }
    }

    private func resetPages() {
        currentPage = 0
        totalPageCount = 1
        pages.removeAll()
        items.value.removeAll()
    }
    
    private func loadAllUsers(loading: UsersListViewModelLoading) {
        self.loading.value = loading

        usersLoadTask = listAllUsersUseCase.execute(
            requestValue: .init(page: nextPage),
            cached: appendPage,
            completion: { result in
                switch result {
                case .success(let page):
                    self.appendPage(page)
                case .failure(let error):
                    self.handle(error: error)
                }
                self.loading.value = .none
        })
    }

    private func load(userQuery: UserQuery, loading: UsersListViewModelLoading) {
        self.loading.value = loading
        query.value = userQuery.query

        usersLoadTask = searchUsersUseCase.execute(
            requestValue: .init(query: userQuery, page: nextPage),
            cached: appendPage,
            completion: { result in
                switch result {
                case .success(let page):
                    self.appendPage(page)
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

    private func update(userQuery: UserQuery) {
        resetPages()
        load(userQuery: userQuery, loading: .fullScreen)
    }
}

// MARK: - INPUT. View event methods

extension DefaultUsersListViewModel {

    func viewDidLoad() {
        loadAllUsers(loading: .nextPage)
    }

    func didLoadNextPage() {
        guard loading.value == .none else { return }
        loadAllUsers(loading: .nextPage)
    }

    func didSearch(query: String) {
        guard !query.isEmpty else { return }
        update(userQuery: UserQuery(query: query))
    }

    func didCancelSearch() {
        usersLoadTask?.cancel()
    }

    func didSelectItem(at index: Int) {
        actions?.showUserDetails(pages.users[index].login ?? "") { note in
            // update the note for that user and reload data
            //self.pages.users[index].note = note
            // determine page size - self.pages.first.count
            // determine which page - index%page size
            // replace page by reinit then
            if let pageSize = self.pages.first?.users.count {
                let page = Int(Float(index / pageSize).rounded(.up))
                self.pages[page] = UsersPage.init(since: self.pages[page].since, per_page: self.pages[page].per_page, users: self.pages[page].users.map {
                    if $0.id == note.userId {
                        return User.init(login: $0.login, id: $0.id, avatar_url: $0.avatar_url, type: $0.type, note: note, following: $0.following, followers: $0.followers, company: $0.company, blog: $0.blog)
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
