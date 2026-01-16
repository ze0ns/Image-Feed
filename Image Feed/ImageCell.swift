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
    
      // UI-элементы
      private let imagesView = UIImageView()
      private let titleLabel = UILabel()
      private let dateLabel = UILabel()
      
      private var imageHeightConstraint: NSLayoutConstraint!
      
      
      override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
          super.init(style: style, reuseIdentifier: reuseIdentifier)
          setupViews()
          setupConstraints()
      }
      
      required init?(coder aDecoder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
      }
      
      // Настройка UI
      private func setupViews() {
          // ImageView
          imagesView.contentMode = .scaleAspectFill
          imagesView.clipsToBounds = true
          imagesView.translatesAutoresizingMaskIntoConstraints = false
          
          // Title Label
          titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
          titleLabel.numberOfLines = 0
          titleLabel.translatesAutoresizingMaskIntoConstraints = false
          // Date Label
          dateLabel.font = .systemFont(ofSize: 12, weight: .regular)
          dateLabel.textColor = .secondaryLabel
          dateLabel.translatesAutoresizingMaskIntoConstraints = false
          
          
          // Добавляем в contentView
          contentView.addSubview(imagesView)
          contentView.addSubview(titleLabel)
          contentView.addSubview(dateLabel)
      }
      
      // Ограничения Auto Layout
      private func setupConstraints() {
          NSLayoutConstraint.activate([
              // ImageView: растягивается по ширине, высота динамическая
              imagesView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
              imagesView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
              imagesView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
              
              // TitleLabel под ImageView
              titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
              titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
              titleLabel.topAnchor.constraint(equalTo: imagesView.bottomAnchor, constant: 8),
              
              // DateLabel под TitleLabel
              dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
              dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
              dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
              dateLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
          ])
          
          
          // Ограничение высоты ImageView (будет обновляться)
          imageHeightConstraint = imagesView.heightAnchor.constraint(equalToConstant: 0)
          imageHeightConstraint.isActive = true
      }
      
      // Метод для заполнения данными
      func configure(
          image: UIImage,
          title: String,
          date: String,
          maxImageWidth: CGFloat
      ) {
          // 1. Устанавливаем изображение
          imagesView.image = image
          
          // 2. Рассчитываем высоту изображения с сохранением пропорций
          let imageAspect = image.size.height / image.size.width
          let calculatedHeight = maxImageWidth * imageAspect
          
          imageHeightConstraint.constant = calculatedHeight
          
          
          // 3. Заполняем текст
          titleLabel.text = title
          dateLabel.text = date
      }
  }


