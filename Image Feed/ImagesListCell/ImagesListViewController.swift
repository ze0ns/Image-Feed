//
//  LaunchScreenViewController.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 15.01.2026.
//

import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListViewController: UIViewController {
    // MARK: - Private Properties
    private let tableView = UITableView()
    private let cellId = "ImagesListCell"
    private var photos: [Photo] = []
    private var isLoading = false
    private lazy var dateForma: DateFormatter = {
         let formatter = DateFormatter()
         formatter.dateFormat = "dd MMMM yyyy"
         formatter.locale = Locale(identifier: "ru_RU")
         return formatter
     }()
    private let dateFormatter = ISO8601DateFormatter()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        setupTableView()
        configureTable()
        fetchInitialPhotos()
    }
    
    // MARK: - Private Methods
    private func setupTableView() {
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: cellId)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .ypBlack
        tableView.separatorStyle = .none
    }
    
    private func configureTable() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    private func fetchInitialPhotos() {
        ImagesListService.shared.fetchPhotosNextPage { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.updateTableViewAnimated()
                case .failure(let error):
                    print("Ошибка загрузки фото: \(error)")
                }
            }
        }
    }
    
    private func updateTableViewAnimated() {
        let newPhotos = ImagesListService.shared.images
        let oldCount = photos.count
        let newCount = newPhotos.count
        
        guard newCount > oldCount else { return }
        
        photos = newPhotos
        
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map { i in
                IndexPath(row: i, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in
            self.isLoading = false
        }
    }
    
    private func updatePhotoLikeStatus(photoId: String, isLiked: Bool) {
        if let index = photos.firstIndex(where: { $0.id == photoId }) {
            var updatedPhoto = photos[index]
            updatedPhoto.likedByUser = isLiked
            photos[index] = updatedPhoto

            if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? ImagesListCell {
                cell.setIsLiked(isLiked)
            }
        }
    }
}

// MARK: - Extension TableViewCell
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        let photo = photos[indexPath.row]
        let maxImageWidth = tableView.bounds.width - 32

        var imageData = "Неизвестная дата"
        
        if let createdAt = photo.createdAt,
           let date = dateFormatter.date(from: createdAt) {
            imageData = dateForma.string(from: date)
        }
        
        cell.configure(
            image: photo.urls.thumb,
            height: photo.height,
            width: photo.width,
            islike: photo.likedByUser,
            date: imageData,
            maxImageWidth: maxImageWidth
        )
        cell.selectionStyle = .none
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 3 && !isLoading {
            isLoading = true
            ImagesListService.shared.fetchPhotosNextPage { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.updateTableViewAnimated()
                    case .failure(let error):
                        print("Ошибка загрузки следующей страницы: \(error)")
                        self?.isLoading = false
                    }
                }
            }
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        let singleImageVC = SingleImageViewController()
        
        singleImageVC.fullImageURL = photo.urls.full
        
        let navController = UINavigationController(rootViewController: singleImageVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let tableViewWidth = tableView.bounds.width - 32
        let aspectRatio = CGFloat(photo.height) / CGFloat(photo.width)
        return tableViewWidth * aspectRatio + 8
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        let newLikeStatus = !photo.likedByUser
        UIBlockingProgressHUD.show()
        ImagesListService.shared.changeLike(photoId: photo.id, isLike: newLikeStatus) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.updatePhotoLikeStatus(photoId: photo.id, isLiked: newLikeStatus)
                    UIBlockingProgressHUD.dismiss()
                case .failure(let error):
                    UIBlockingProgressHUD.dismiss()
                    let alert = UIAlertController(
                        title: "Ошибка",
                        message: "Не удалось изменить лайк: \(error.localizedDescription)",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                    cell.setIsLiked(photo.likedByUser)
                }
            }
        }
    }
}
