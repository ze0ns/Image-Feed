//
//  ImagesListPresenter.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 23.02.2026.
//
import UIKit
import Kingfisher
protocol ImagesListPresenterProtocol: AnyObject {
    var photosCount: Int { get }
    func viewDidLoad()
    func getPhoto(at index: Int) -> Photo
    func fetchNextPage()
    func didTapLike(at indexPath: IndexPath)
    func didSelectPhoto(at index: Int)
    func formatDate(_ date: Date?) -> String
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    // MARK: - Properties
    private weak var view: ImagesListViewProtocol?
    private let imagesListService: ImagesListService
    private var photos: [Photo] = []
    private var isLoading = false
    private let dateFormatter: DateFormatter
    
    var photosCount: Int {
        return photos.count
    }
    
    // MARK: - Initializer
    init(view: ImagesListViewProtocol,
         imagesListService: ImagesListService = .shared,
         dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMMM yyyy"
            formatter.locale = Locale(identifier: "ru_RU")
            return formatter
         }()) {
        self.view = view
        self.imagesListService = imagesListService
        self.dateFormatter = dateFormatter
    }
    
    // MARK: - Public Methods
    func viewDidLoad() {
        fetchNextPage()
        view?.hideLoading()
    }
    
    func getPhoto(at index: Int) -> Photo {
        return photos[index]
    }
    
    func fetchNextPage() {
        guard !isLoading else { return }
        
        isLoading = true
        view?.showLoading()
        
        imagesListService.fetchPhotosNextPage { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.view?.hideLoading()
                
                switch result {
                case .success(let newPhotos):
                    self.handleNewPhotos(newPhotos)
                case .failure(let error):
                    self.view?.showError(message: "Ошибка загрузки фото: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func didTapLike(at indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        let newLikeStatus = !photo.likedByUser
        
        view?.showLoading()
        
        imagesListService.changeLike(photoId: photo.id, isLike: newLikeStatus) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.view?.hideLoading()
                
                switch result {
                case .success:
                    self.updatePhotoLikeStatus(photoId: photo.id, isLiked: newLikeStatus)
                    self.view?.updateCellLikeStatus(at: indexPath, isLiked: newLikeStatus)
                    
                case .failure(let error):
                    self.view?.showError(message: "Не удалось изменить лайк: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func didSelectPhoto(at index: Int) {
        let photo = photos[index]
        view?.navigateToSingleImage(with: photo.fullImageURL)
    }
    
    func formatDate(_ date: Date?) -> String {
        guard let date = date else {
            return ""
        }
        return dateFormatter.string(from: date)
    }
    
    // MARK: - Private Methods
    private func handleNewPhotos(_ newPhotos: [Photo]) {
        let oldCount = photos.count
        photos = imagesListService.photos
        let newCount = photos.count
        
        guard newCount > oldCount else { return }
        
        view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
    }
    
    private func updatePhotoLikeStatus(photoId: String, isLiked: Bool) {
        if let index = photos.firstIndex(where: { $0.id == photoId }) {
            var updatedPhoto = photos[index]
            updatedPhoto.likedByUser = isLiked
            photos[index] = updatedPhoto
        }
    }
}
