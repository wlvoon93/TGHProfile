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
    let showUserDetails: (User) -> Void
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
    private let actions: UsersListViewModelActions?

    var currentPage: Int = 0
    var totalPageCount: Int = 1
    var hasMorePages: Bool { currentPage < totalPageCount }
    var nextPage: Int { hasMorePages ? currentPage + 1 : currentPage }

    private var pages: [UsersPage] = []
    private var usersLoadTask: Cancellable? { willSet { usersLoadTask?.cancel() } }

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
         actions: UsersListViewModelActions? = nil) {
        self.searchUsersUseCase = searchUsersUseCase
        self.listAllUsersUseCase = listAllUsersUseCase
        self.actions = actions
    }

    // MARK: - Private

    private func appendPage(_ usersPage: UsersPage) {
        currentPage = 1
//        totalPageCount = usersPage.totalPages

        pages = pages
            .filter { $0.since != usersPage.since }
            + [usersPage]
//        pages = usersPage

        items.value = pages.users.map(UsersListItemViewModel.init)
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
        guard hasMorePages, loading.value == .none else { return }
        load(userQuery: .init(query: query.value),
             loading: .nextPage)
    }

    func didSearch(query: String) {
        guard !query.isEmpty else { return }
        update(userQuery: UserQuery(query: query))
    }

    func didCancelSearch() {
        usersLoadTask?.cancel()
    }

    func didSelectItem(at index: Int) {
        actions?.showUserDetails(pages.users[index])
    }
}

// MARK: - Private

private extension Array where Element == UsersPage {
    var users: [User] { flatMap { $0.users } }
}
