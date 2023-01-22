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
    private var posterImagesRepository: PosterImagesRepository?

    private var usersTableViewController: UsersListTableViewController?
    private var searchController = UISearchController(searchResultsController: nil)

    // MARK: - Lifecycle

    static func create(with viewModel: UsersListViewModel,
                       posterImagesRepository: PosterImagesRepository?) -> UsersListViewController {
        let view = UsersListViewController()
        view.viewModel = viewModel
        view.posterImagesRepository = posterImagesRepository
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
            usersTableViewController?.posterImagesRepository = posterImagesRepository
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
        usersTableViewController?.posterImagesRepository = posterImagesRepository
        
        guard let usersTableViewController = usersTableViewController else { return }
        usersTableViewController.tableView.backgroundColor = .black
        usersTableViewController.tableView.translatesAutoresizingMaskIntoConstraints = true
        usersTableViewController.tableView.frame = rootView.searchBarContainerView.bounds
        usersTableViewController.tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        rootView.usersListContainerView.addSubview(usersTableViewController.tableView)
    }
}

// MARK: - Search Controller

extension UsersListViewController {
    private func setupSearchController() {
//        searchController.delegate = self
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
        if #available(iOS 13.0, *) {
            searchController.searchBar.searchTextField.accessibilityIdentifier = AccessibilityIdentifier.searchField
        }
    }
}

extension UsersListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        searchController.isActive = false
        viewModel.didSearch(query: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.didCancelSearch()
    }
}
