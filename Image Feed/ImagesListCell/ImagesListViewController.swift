//
//  LaunchScreenViewController.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 15.01.2026.
//
//   private var imageLists =  ImagesListViewController.imagesListMock

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    // MARK: - Private Properties
    private let tableView = UITableView()
    private let cellId = "ImagesListCell"
    private var photos: [Photo] = []
    private var isLoading = false
    var imageURL = UIImage(resource: ._13)
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
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
        tableView.register(ImageCell.self, forCellReuseIdentifier: cellId)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .ypBlack
        tableView.separatorStyle = .none
    }
    private func configureTable(){
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
    private func changeRootToDestination() {
        let fullScreenImageVC = SingleImageViewController()
        fullScreenImageVC.imageURL = imageURL
        let navController = UINavigationController(rootViewController: fullScreenImageVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
}
// MARK: - Extension TableViewCell
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ImageCell
        let photo = photos[indexPath.row]
        let maxImageWidth = tableView.bounds.width - 32
        
        cell.configure(
            image: photo.urls.thumb,
            height: photo.height,
            width: photo.width,
            islike: UIImage(resource: photo.liked_by_user ? .likeButtonOn : .likeButtonOff),
            date: dateFormatter.string(from: Date()),
            maxImageWidth: maxImageWidth
        )
        cell.selectionStyle = .none
        
        // Загружаем полноразмерное изображение
        if let url = URL(string: photo.urls.full) {
            KingfisherManager.shared.retrieveImage(with: url) { result in
                switch result {
                case .success(let value):
                    DispatchQueue.main.async {
                        if let currentCell = tableView.cellForRow(at: indexPath) as? ImageCell {
                            currentCell.imageView?.image = value.image
                            self.imageURL = value.image
                        }
                    }
                case .failure(let error):
                    print("Ошибка загрузки изображения: \(error)")
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Загружаем следующую страницу когда приближаемся к концу списка
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
        
        // Передаем URL полноразмерного изображения
        singleImageVC.imageURL =  self.imageURL
        
        let navController = UINavigationController(rootViewController: singleImageVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let tableViewWidth = tableView.bounds.width - 32
        let aspectRatio = CGFloat(photo.height) / CGFloat(photo.width)
        return tableViewWidth * aspectRatio + 8 // Добавляем отступы
    }
}

//extension ImagesListViewController: UITableViewDelegate{
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let currentImage = photos[indexPath.row]
// //       imageURL = currentImage.urls.thumb
//        changeRootToDestination()
//    }
//}

