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
    func getPhoto(at index: Int) -> Photo?
    func fetchNextPage()
    func didTapLike(at indexPath: IndexPath)
    func didSelectPhoto(at index: Int)
    func formatDate(_ date: Date?) -> String
}

// MARK: - Updated Presenter with Protocol Dependency
final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    // MARK: - Properties
    private weak var view: ImagesListViewProtocol?
    private let imagesListService: ImagesListServiceProtocol
    private var photos: [Photo] = []
    private var isLoading = false
    private let dateFormatter: DateFormatter
    
    var photosCount: Int {
        return photos.count
    }
    
    // MARK: - Initializer
    init(view: ImagesListViewProtocol,
         imagesListService: ImagesListServiceProtocol,
         dateFormatter: DateFormatter) {
        self.view = view
        self.imagesListService = imagesListService
        self.dateFormatter = dateFormatter
    }
    
    // MARK: - Public Methods
    func viewDidLoad() {
        fetchNextPage()
    }
    
    // Безопасное получение фото по индексу
    func getPhoto(at index: Int) -> Photo? {
//        guard index >= 0, index < photos.count else {
//            print("⚠️ [ImagesListPresenter] - Попытка получить фото по несуществующему индексу: \(index)")
//            return nil
//        }
        guard index >= 0, index < photos.count else { return nil }
        return photos[index]
    }
    
    func fetchNextPage() {
        guard !isLoading else {
            print("⚠️ [ImagesListPresenter] - Загрузка уже выполняется")
            return
        }
        
        isLoading = true
        
        imagesListService.fetchPhotosNextPage { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
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
        guard let photo = getPhoto(at: indexPath.row) else {
            print("⚠️ [ImagesListPresenter] - Не удалось получить фото для лайка по индексу: \(indexPath.row)")
            return
        }
        
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
        guard let photo = getPhoto(at: index) else {
            print("⚠️ [ImagesListPresenter] - Не удалось получить фото для навигации по индексу: \(index)")
            return
        }
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
        
        guard newCount > oldCount else {
            print("⚠️ [ImagesListPresenter] - Нет новых фото для добавления")
            return
        }
        
        view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
    }
    
    private func updatePhotoLikeStatus(photoId: String, isLiked: Bool) {
        if let index = photos.firstIndex(where: { $0.id == photoId }) {
            var updatedPhoto = photos[index]
            updatedPhoto.likedByUser = isLiked
            photos[index] = updatedPhoto
        } else {
            print("⚠️ [ImagesListPresenter] - Не найдено фото с id: \(photoId) для обновления лайка")
        }
    }
}
