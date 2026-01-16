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
    var imageHigth:CGFloat = 100
    
    private lazy var imagesView: UIImageView = {
        let imagesView = UIImageView()
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
        imagesView.layer.cornerRadius = 16
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
            imagesView.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            imagesView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            imagesView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 20),
            imagesView.heightAnchor.constraint(equalTo: self.heightAnchor),
            imagesView.widthAnchor.constraint(equalTo: self.widthAnchor)

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


