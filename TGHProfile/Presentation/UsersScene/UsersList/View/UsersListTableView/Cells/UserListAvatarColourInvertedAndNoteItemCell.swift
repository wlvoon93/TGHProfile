//
//  UserListAvatarColourInvertedAndNoteItemCell.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 27/12/2022.
//

import UIKit

final class UserListAvatarColourInvertedAndNoteItemCell: UITableViewCell, BaseItemCell {
    internal var viewModel: BaseItemViewModel?
  
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
    
    private lazy var noteImageView: UIImageView = {
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        icon.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        icon.image = UIImage(named: "note")
        
        return icon
    }()

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
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        userNameLabel.text = nil
        userTypeLabel.text = nil
    }

    func fill(with viewModel: BaseItemViewModel, profileImagesRepository: ProfileImagesRepository?) {
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
        contentView.addSubview(noteImageView)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),
            profileImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            userNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 5),
            userNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            userNameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            
            userTypeLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor),
            userTypeLabel.trailingAnchor.constraint(equalTo: userNameLabel.trailingAnchor),
            userTypeLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 5),
            
            noteImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            noteImageView.topAnchor.constraint(equalTo: userNameLabel.topAnchor),
            noteImageView.heightAnchor.constraint(equalToConstant: 25),
            noteImageView.widthAnchor.constraint(equalToConstant: 25)
        ])
    }

    private func updateProfileImage(width: Int) {
        guard let profileImagePath = viewModel?.user.profileImage?.imageUrl else { return }

        imageLoadTask = profileImagesRepository?.fetchImage(with: profileImagePath, width: width) { [weak self] result in
            guard let self = self else { return }
            guard self.viewModel?.user.profileImage?.imageUrl == profileImagePath else { return }
            if case let .success(data) = result {
                if let filter = CIFilter(name: "CIColorInvert"), let initialImage = UIImage(data: data) {
                    let beginImage = CIImage(image: initialImage)
                    filter.setValue(beginImage, forKey: kCIInputImageKey)
                    if let outputCiimage = filter.outputImage,
                        let filteredImageData = UIImage(ciImage: outputCiimage).pngData() {
                        
                        self.profileImageView.image = UIImage(data: filteredImageData)
                        
                        if let userId = self.viewModel?.user.userId {
                            self.profileImageView.image = UIImage(data: filteredImageData)
                            _ = self.profileImagesRepository?.saveImage(userId: userId, imageData: data, completion: { _ in
                                
                            })
                            _ = self.profileImagesRepository?.saveInvertedImage(userId: userId, imageData: filteredImageData, completion: { _ in
                                
                            })
                        }
                    }
                }
            }
            self.imageLoadTask = nil
        }
    }
}
