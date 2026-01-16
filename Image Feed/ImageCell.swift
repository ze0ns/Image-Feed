//
//  ImageCell.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 16.01.2026.
//

import UIKit

protocol SelfConfiguringCell {
    static var reuseID: String {get}
    func configure(with value: ImageViewCell)
}
class ImageCell: UITableViewCell, SelfConfiguringCell {
    static var reuseID = "ImagesListCell"
    
    private lazy var imagesView: UIImageView = {
        let imagesView = UIImageView()
        imagesView.sizeToFit()
        return imagesView
    }()
    
    private lazy var likes: UIButton = {
        let likes = UIButton()
        return likes
    }()
    
    private lazy var dateOfPublic: UILabel = {
        let dateOfPublic = UILabel()
        return dateOfPublic
    }()
    
    
    func configure(with value: ImageViewCell) {
        imagesView.image = UIImage(named: value.image)
        likes.isEnabled = value.like
        dateOfPublic.text = value.date
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
//MARK: - Setup Constrains
extension ImageCell{
    private func setupConstraints(){
        imagesView.translatesAutoresizingMaskIntoConstraints = false
        likes.translatesAutoresizingMaskIntoConstraints = false
        dateOfPublic.translatesAutoresizingMaskIntoConstraints = false
           
        addSubview(imagesView)
        addSubview(likes)
        addSubview(dateOfPublic)

        
        NSLayoutConstraint.activate([
            imagesView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            imagesView.centerYAnchor.constraint(equalTo: self.centerYAnchor),

        ])
        NSLayoutConstraint.activate([
            likes.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            likes.leadingAnchor.constraint(equalTo: imagesView.trailingAnchor, constant: 16),
            likes.trailingAnchor.constraint(equalTo: dateOfPublic.trailingAnchor, constant: -20)
        ])
        NSLayoutConstraint.activate([
            dateOfPublic.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -14),
            dateOfPublic.leadingAnchor.constraint(equalTo: likes.trailingAnchor, constant: 16)
        ])


}
}


