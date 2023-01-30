//
//  UserListAvatarColourInvertedItemCell.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 27/12/2022.
//

import UIKit

final class UserListAvatarColourInvertedItemCell: UITableViewCell, UserListTVCDisplayable {

    static let reuseIdentifier = String(describing: UsersListItemCell.self)
    static let height = CGFloat(130)
    var profileImage: UIImage?
    
    private lazy var profileImageView: UIImageView = {
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        icon.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        
        return icon
    }()
    
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 25.0)
        return label
    }()

    private lazy var userTypeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    internal var viewModel: UserListTVCVMDisplayable?
    private var profileImagesRepository: ProfileImagesRepository?
    private var imageLoadTask: Cancellable? { willSet { imageLoadTask?.cancel() } }
    
    // MARK: - Initializer and Lifecycle Methods -
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        userNameLabel.text = nil
        userTypeLabel.text = nil
    }

    func fill(with viewModel: UserListTVCVMDisplayable, profileImagesRepository: ProfileImagesRepository?) {
        self.viewModel = viewModel
        self.profileImagesRepository = profileImagesRepository

        userNameLabel.text = viewModel.user.login
        userTypeLabel.text = viewModel.user.type
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
            profileImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8),
            
            userNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 5),
            userNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            userNameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            
            userTypeLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor),
            userTypeLabel.trailingAnchor.constraint(equalTo: userNameLabel.trailingAnchor),
            userTypeLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 5)
        ])
    }

    private func updateProfileImage(width: Int) {
        guard let profileImagePath = viewModel?.user.profileImage?.imageUrl else { return }
        
        if let userId = self.viewModel?.user.userId {
            imageLoadTask = profileImagesRepository?.fetchImage(for: userId,  imagePath: profileImagePath) { [weak self] profileImage in
                guard let self = self else { return }
                if let imageData = profileImage.invertedImage, let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self.profileImageView.image = image
                    }
                }
            } completion: { [weak self] result in
                guard let self = self else { return }
                if case let .success(data) = result {
                    if let filter = CIFilter(name: "CIColorInvert"),
                        let initialImage = UIImage(data: data) {
                        let beginImage = CIImage(image: initialImage)
                        filter.setValue(beginImage, forKey: kCIInputImageKey)
                        if let outputCiimage = filter.outputImage,
                            let filteredImageData = UIImage(ciImage: outputCiimage).pngData() {
                            DispatchQueue.main.async {
                                self.profileImageView.image = UIImage(data: filteredImageData)
                            }
                            _ = self.profileImagesRepository?.saveImage(userId: userId, imageData: data, completion: { _ in
                                
                            })
                            _ = self.profileImagesRepository?.saveInvertedImage(userId: userId, imageData: filteredImageData, completion: { _ in
                                
                            })
                        }
                    }
                    self.imageLoadTask = nil
                }
            }
        }
    }
}
