//
//  UsersListViewController.swift
//  ExampleMVVM
//
//  Created by T0366-ADE-MB-1 on 15/12/2022.
//

import UIKit
import Combine

final class UsersListViewController: UIViewController, StoryboardInstantiable, Alertable {
    
    // MARK: - Properties -
    var rootView: UsersListView {
        return view as! UsersListView
    }
    
    private var viewModel: UsersListViewModel!
    private var profileImagesRepository: ProfileImagesRepository?

    private var usersTableViewController: UsersListTableViewController?
    private var searchUserTableViewController: SearchUserListTableViewController?
    private var searchController = UISearchController(searchResultsController: nil)
    
    var subsciptions = Set<AnyCancellable>()

    // MARK: - Lifecycle

    static func create(with viewModel: UsersListViewModel,
                       profileImagesRepository: ProfileImagesRepository?) -> UsersListViewController {
        let view = UsersListViewController()
        view.viewModel = viewModel
        view.profileImagesRepository = profileImagesRepository
        return view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBehaviours()
        setupReachability()
        bind(to: viewModel)
        viewModel.viewDidLoad()
    }

    private func bind(to viewModel: UsersListViewModel) {
        viewModel.items.sink {  [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.updateItems()
        }.store(in: &subsciptions)
        
        viewModel.searchItems.sink { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.updateSearchItems()
        }.store(in: &subsciptions)
        
        viewModel.loading.sink { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.updateLoading($0)
        }.store(in: &subsciptions)
        
        viewModel.query.sink { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.updateSearchQuery($0)
        }.store(in: &subsciptions)
        
        viewModel.error.sink { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.showError($0)
        }.store(in: &subsciptions)
        
        viewModel.tableMode.sink { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.displayTable($0)
            strongSelf.title = ($0 == TableMode.listAll) ? "Users" : "Search User"
        }.store(in: &subsciptions)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.isActive = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == String(describing: UsersListTableViewController.self),
            let destinationVC = segue.destination as? UsersListTableViewController {
            usersTableViewController = destinationVC
            usersTableViewController?.viewModel = viewModel
            usersTableViewController?.profileImagesRepository = profileImagesRepository
        }
    }
    
    public override func loadView() {
        view = UsersListView(frame: UIScreen.main.bounds)
    }

    // MARK: - Private

    private func setupViews() {
        title = viewModel.screenTitle
        rootView.emptyDataLabel.text = viewModel.emptyDataTitle
        setupSearchController()
        setupTableController()
        setupSearchTableController()
    }

    private func setupBehaviours() {
        addBehaviors([BackButtonEmptyTitleNavigationBarBehavior(),
                      BlackStyleNavigationBarBehavior()])
    }
    
    private func setupReachability() {
        NotificationCenter.default.addObserver(self, selector: #selector(showOfflineDeviceUI(notification:)), name: NSNotification.Name.connectivityStatus, object: nil)
    }
    
    @objc func showOfflineDeviceUI(notification: Notification) {
        if NetworkMonitor.shared.isConnected {
            print("Connected")
            if !viewModel.isConnected {
                viewModel.isConnected = true
                viewModel.didLoadFirstPage()
            }
        } else {
            print("Not connected")
            if viewModel.isConnected {
                viewModel.isConnected = false
                viewModel.handleReachabilityNoInternet()
            }
        }
    }

    private func updateItems() {
        usersTableViewController?.reload()
    }
    
    private func updateSearchItems() {
        searchUserTableViewController?.reload()
    }

    private func updateLoading(_ loading: UsersListViewModelLoading?) {
        DispatchQueue.main.async {
            self.rootView.emptyDataLabel.isHidden = true
            self.rootView.usersListContainerView.isHidden = true
            self.rootView.suggestionsListContainerView.isHidden = true
            LoadingView.hide()

            switch loading {
            case .fullScreen: LoadingView.show()
            case .nextPage: self.rootView.usersListContainerView.isHidden = false
            case .none:
                self.rootView.usersListContainerView.isHidden = (self.viewModel.isEmpty && self.viewModel.tableMode.value == .listAll) || (self.viewModel.isSearchEmpty && self.viewModel.tableMode.value == .search)
                self.rootView.emptyDataLabel.isHidden = !(self.viewModel.isEmpty && self.viewModel.tableMode.value == .listAll) || !(self.viewModel.isSearchEmpty && self.viewModel.tableMode.value == .search)
            }

            self.usersTableViewController?.updateLoading(loading)
        }
    }
    
    private func displayTable(_ tableMode: TableMode) {
        switch tableMode {
        case .listAll:
            rootView.usersListContainerView.isHidden = false
            rootView.searchUserListContainerView.isHidden = true
        case .search:
            rootView.usersListContainerView.isHidden = true
            rootView.searchUserListContainerView.isHidden = false
        }
    }

    private func updateSearchQuery(_ query: String) {
        searchController.isActive = false
        searchController.searchBar.text = query
    }

    private func showError(_ error: String) {
        DispatchQueue.main.async {
            guard !error.isEmpty, let topViewController = UIApplication.getTopViewController(), !topViewController.isKind(of: UIAlertController.self) else { return }
        
            self.showAlert(title: self.viewModel.errorTitle, message: error)
        }
    }
}

// MARK: - Table Controller

extension UsersListViewController {
    private func setupTableController() {
        usersTableViewController = UsersListTableViewController()
        usersTableViewController?.viewModel = viewModel
        usersTableViewController?.profileImagesRepository = profileImagesRepository
        
        guard let usersTableViewController = usersTableViewController else { return }
        usersTableViewController.tableView.backgroundColor = .lightGray
        usersTableViewController.tableView.translatesAutoresizingMaskIntoConstraints = true
        usersTableViewController.tableView.frame = rootView.searchBarContainerView.bounds
        usersTableViewController.tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        rootView.usersListContainerView.addSubview(usersTableViewController.tableView)
    }
}

// setup search table
extension UsersListViewController {
    private func setupSearchTableController() {
        searchUserTableViewController = SearchUserListTableViewController()
        searchUserTableViewController?.viewModel = viewModel
        searchUserTableViewController?.profileImagesRepository = profileImagesRepository
        
        guard let searchUserTableViewController = searchUserTableViewController else { return }
        searchUserTableViewController.tableView.backgroundColor = .black
        searchUserTableViewController.tableView.translatesAutoresizingMaskIntoConstraints = true
        searchUserTableViewController.tableView.frame = rootView.searchBarContainerView.bounds
        searchUserTableViewController.tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        rootView.searchUserListContainerView.addSubview(searchUserTableViewController.tableView)
    }
}

// MARK: - Search Controller

extension UsersListViewController {
    private func setupSearchController() {
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = viewModel.searchBarPlaceholder
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.translatesAutoresizingMaskIntoConstraints = true
        searchController.searchBar.barStyle = .black
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.frame = rootView.searchBarContainerView.bounds
        searchController.searchBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        rootView.searchBarContainerView.addSubview(searchController.searchBar)
        definesPresentationContext = true
        searchController.searchBar.searchTextField.accessibilityIdentifier = AccessibilityIdentifier.searchField
    }
}

extension UsersListViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        viewModel.tableMode.value = .search
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        searchController.isActive = false
        viewModel.didSearch(query: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.didCancelSearch()
        viewModel.tableMode.value = .listAll
        viewModel.resetSearchPages()
    }
}
