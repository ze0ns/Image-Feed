//
//  ImageCell.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 16.01.2026.
//

import UIKit
import Kingfisher

protocol SelfConfiguringCell {
    static var reuseID: String {get}
}

final class ImageCell: UITableViewCell, SelfConfiguringCell {
    static var reuseID = "ImagesListCell"
    
    // MARK: - Private Properties
    private let imagesView = UIImageView()
    private lazy var isLiked: Bool = false
    private let dateLabel = UILabel()
    private lazy var like: UIButton = UIButton()
    
    private var imageHeightConstraint: NSLayoutConstraint!
    // MARK: - Public Properties, Delegate
    weak var delegate: ImagesListCellDelegate?
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .ypBlack
        setupViews()
        setupConstraints()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    // MARK: - Private Methods, setup View
    private func setupViews() {
        
        imagesView.contentMode = .scaleAspectFill
        imagesView.clipsToBounds = true
        imagesView.layer.cornerRadius = 16
        imagesView.translatesAutoresizingMaskIntoConstraints = false
        
        like.addTarget(self, action: #selector(likeButtonClicked), for: .touchUpInside)
        like.translatesAutoresizingMaskIntoConstraints = false
        
        dateLabel.font = .systemFont(ofSize: 13, weight: .regular)
        dateLabel.textColor = .ypWhite
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(imagesView)
        contentView.addSubview(like)
        contentView.addSubview(dateLabel)
    }
    // MARK: - Private Methods, setup Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            imagesView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            imagesView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            imagesView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            imagesView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -4),
            
            like.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            like.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            like.widthAnchor.constraint(equalToConstant: 44),
            like.heightAnchor.constraint(equalToConstant: 44),
            
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            dateLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])
        
        imageHeightConstraint = imagesView.heightAnchor.constraint(equalToConstant: 0)
        imageHeightConstraint.isActive = true
    }
    // MARK: - Public Methods, Configure Cell
    func configure(
        image: String,
        height: Int,
        width: Int,
        islike: Bool,
        date: String,
        maxImageWidth: CGFloat
    ) {
        updateImage(imageString: image)
        let imageAspect = CGFloat(height) / CGFloat(width)
        let calculatedHeight = maxImageWidth * imageAspect
        imageHeightConstraint.constant = calculatedHeight
        let userLiked = UIImage(resource: islike ? .likeButtonOn : .likeButtonOff)
        like.setBackgroundImage(userLiked, for: .normal)
        dateLabel.text = date
    }
    private func updateImage(imageString: String){
        let imageUrl = URL(string: imageString)
        let placeholderImage = UIImage(resource:.stub)
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
        let processor = RoundCornerImageProcessor(cornerRadius: 6)
        imagesView.kf.indicatorType = .activity
        imagesView.kf.setImage(
            with: imageUrl,
            placeholder: placeholderImage,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .forceRefresh
            ]) { result in
                switch result {
                case .success(let value):
                    print(value.image)
                case .failure(let error):
                    print(error)
                }
            }
    }
    func setIsLiked(_ isLiked: Bool) {
        like.isSelected = isLiked
        let imageName = isLiked ? "like_button_on" : "like_button_off"
        like.setImage(UIImage(named: imageName), for: .normal)
    }
    @objc private func likeButtonClicked() {
       delegate?.imageListCellDidTapLike(self)
    }
}
