//
//  UsersListItemCell.swift
//  ExampleMVVM
//
//  Created by T0366-ADE-MB-1 on 19/12/2022.
//

import UIKit

final class UsersListItemCell: UITableViewCell {

    static let reuseIdentifier = String(describing: UsersListItemCell.self)
    static let height = CGFloat(130)
    
    private lazy var profileImageView: UIImageView = {
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        icon.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        
        return icon
    }()
    
    private lazy var userNameLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        return view
    }()

    private lazy var userTypeLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        return view
    }()

    private var viewModel: UsersListItemViewModel!
    private var profileImagesRepository: ProfileImagesRepository?
    private var imageLoadTask: Cancellable? { willSet { imageLoadTask?.cancel() } }
    
    // MARK: - Initializer and Lifecycle Methods -
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
        contentView.backgroundColor = .white
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func fill(with viewModel: UsersListItemViewModel, profileImagesRepository: ProfileImagesRepository?) {
        self.viewModel = viewModel
        self.profileImagesRepository = profileImagesRepository

        userNameLabel.text = viewModel.username
        userTypeLabel.text = viewModel.type
        updateProfileImage(width: Int(profileImageView.imageSizeAfterAspectFit.scaledSize.width))
    }
    
    // MARK: - Private API -
    private func setupSubviews() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userTypeLabel)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),
            profileImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            userNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 5),
            userNameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            
            userTypeLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor),
            userTypeLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 5)
        ])
        
//        contentView.addSubview(titleLabel)
//        contentView.addSubview(dateLabel)
//        contentView.addSubview(overviewLabel)
//        contentView.addSubview(posterImageView)
//
//        NSLayoutConstraint.activate([
//            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: posterImageView.leadingAnchor, constant: -8),
//            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
//
//            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
//            dateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
//            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
//
//            overviewLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
//            overviewLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
//            overviewLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
//            overviewLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -11),
//
//            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            posterImageView.widthAnchor.constraint(equalToConstant: 80),
//            posterImageView.heightAnchor.constraint(equalToConstant: 109),
//            posterImageView.topAnchor.constraint(equalTo: titleLabel.topAnchor),
//            posterImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -9),
//        ])
    }

    private func updateProfileImage(width: Int) {
        profileImageView.image = nil
        guard let profileImagePath = viewModel.profileImagePath else { return }

        imageLoadTask = profileImagesRepository?.fetchImage(with: profileImagePath, width: width) { [weak self] result in
            guard let self = self else { return }
            guard self.viewModel.profileImagePath == profileImagePath else { return }
            if case let .success(data) = result {
                self.profileImageView.image = UIImage(data: data)
            }
            self.imageLoadTask = nil
        }
    }
}
