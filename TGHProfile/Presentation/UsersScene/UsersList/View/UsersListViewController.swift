//
//  UsersListViewController.swift
//  ExampleMVVM
//
//  Created by T0366-ADE-MB-1 on 15/12/2022.
//

import UIKit

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
        bind(to: viewModel)
        viewModel.viewDidLoad()
    }

    private func bind(to viewModel: UsersListViewModel) {
        viewModel.items.observe(on: self) { [weak self] _ in self?.updateItems() }
        viewModel.loading.observe(on: self) { [weak self] in self?.updateLoading($0) }
        viewModel.query.observe(on: self) { [weak self] in self?.updateSearchQuery($0) }
        viewModel.error.observe(on: self) { [weak self] in self?.showError($0) }
        viewModel.tableMode.observe(on: self) { [weak self] in self?.displayTable($0) }
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
    }

    private func setupBehaviours() {
        addBehaviors([BackButtonEmptyTitleNavigationBarBehavior(),
                      BlackStyleNavigationBarBehavior()])
    }

    private func updateItems() {
        usersTableViewController?.reload()
    }

    private func updateLoading(_ loading: UsersListViewModelLoading?) {
        rootView.emptyDataLabel.isHidden = true
        rootView.usersListContainerView.isHidden = true
        rootView.suggestionsListContainerView.isHidden = true
        LoadingView.hide()

        switch loading {
        case .fullScreen: LoadingView.show()
        case .nextPage: rootView.usersListContainerView.isHidden = false
        case .none:
            rootView.usersListContainerView.isHidden = viewModel.isEmpty
            rootView.emptyDataLabel.isHidden = !viewModel.isEmpty
        }

        usersTableViewController?.updateLoading(loading)
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
        guard !error.isEmpty else { return }
        showAlert(title: viewModel.errorTitle, message: error)
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
        searchController.searchBar.barStyle = .default
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
    }
}
