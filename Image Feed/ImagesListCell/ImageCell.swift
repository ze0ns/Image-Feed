//
//  ImageCell.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 16.01.2026.
//

import UIKit

protocol SelfConfiguringCell {
    static var reuseID: String {get}
}
class ImageCell: UITableViewCell, SelfConfiguringCell {
    static var reuseID = "ImagesListCell"
    
    // MARK: - Private Properties
    private let imagesView = UIImageView()
    private var isLiked: Bool = false
    private let dateLabel = UILabel()
    private var like: UIButton = UIButton()

    private var imageHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .yp_Black
        setupViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Private Methods, setup View
    private func setupViews() {
        
        imagesView.contentMode = .scaleAspectFill
        imagesView.clipsToBounds = true
        imagesView.layer.cornerRadius = 16
        imagesView.translatesAutoresizingMaskIntoConstraints = false
        
        like.translatesAutoresizingMaskIntoConstraints = false
        
        dateLabel.font = .systemFont(ofSize: 13, weight: .regular)
        dateLabel.textColor = .yp_White
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
        image: UIImage,
        islike: UIImage,
        date: String,
        maxImageWidth: CGFloat
    ) {
        imagesView.image = image

        let imageAspect = image.size.height / image.size.width
        let calculatedHeight = maxImageWidth * imageAspect
        
        imageHeightConstraint.constant = calculatedHeight

        like.setBackgroundImage(islike, for: .normal)
        dateLabel.text = date
    }
}
