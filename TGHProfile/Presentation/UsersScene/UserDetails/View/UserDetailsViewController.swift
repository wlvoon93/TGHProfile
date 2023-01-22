//
//  UserDetailsViewController.swift
//  ExampleMVVM
//
//  Created by T0366-ADE-MB-1 on 19/12/2022.
//

import UIKit

final class UserDetailsViewController: UIViewController, StoryboardInstantiable {

    // MARK: - Lifecycle

    private var viewModel: UserDetailsViewModel!
    
    static func create(with viewModel: UserDetailsViewModel) -> UserDetailsViewController {
        let view = UserDetailsViewController.instantiateViewController()
        view.viewModel = viewModel
        return view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bind(to: viewModel)
    }

    private func bind(to viewModel: UserDetailsViewModel) {
//        viewModel.error.observe(on: self) { [weak self] in self?.showError($0) }
//        viewModel.id.observe(on: self) { [weak self] in self?.showError($0) }
//        viewModel.avatarUrl.observe(on: self) { [weak self] in self?.showError($0) }
//        viewModel.type.observe(on: self) { [weak self] in self?.showError($0) }
//        viewModel.note.observe(on: self) { [weak self] in self?.showError($0) }
    }
    
    private func showId() {
//        rootv
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        viewModel.updateProfileImage(width: Int(profileImageView.imageSizeAfterAspectFit.scaledSize.width))
    }

    // MARK: - Private

    private func setupViews() {
//        title = viewModel.title
//        overviewTextView.text = viewModel.overview
//        profileImageView.isHidden = viewModel.isProfileImageHidden
        view.accessibilityIdentifier = AccessibilityIdentifier.userDetailsView
    }
}
