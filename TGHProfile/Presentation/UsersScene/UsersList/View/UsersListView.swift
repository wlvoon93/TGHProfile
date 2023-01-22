//
//  UsersListView.swift
//  ExampleMVVM
//
//  Created by T0366-ADE-MB-1 on 15/12/2022.
//

import Foundation
import UIKit

class UsersListView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        self.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    lazy var usersListContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    lazy var searchUserListContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .green
        return view
    }()
    
    lazy var suggestionsListContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    lazy var searchBarContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    lazy var emptyDataLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private func setupSubviews() {
        addSubview(contentView)
        addSubview(searchBarContainerView)
        addSubview(usersListContainerView)
        addSubview(searchUserListContainerView)
        addSubview(emptyDataLabel)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            
            searchBarContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            searchBarContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            searchBarContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            searchBarContainerView.heightAnchor.constraint(equalToConstant: 56),
            
            usersListContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            usersListContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            usersListContainerView.topAnchor.constraint(equalTo: searchBarContainerView.bottomAnchor),
            usersListContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            searchUserListContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            searchUserListContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            searchUserListContainerView.topAnchor.constraint(equalTo: searchBarContainerView.bottomAnchor),
            searchUserListContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            emptyDataLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor , constant: 16),
            emptyDataLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor , constant: 16),
            emptyDataLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emptyDataLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 28)
        ])
    }
}
