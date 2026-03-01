//
//  ImagesListPresenterTests.swift
//  Image FeedTests
//
//  Created by Oschepkov Aleksandr on 28.02.2026.
//

import XCTest
@testable import Image_Feed
// MARK: - Mock Objects
final class ImagesListServiceMock: ImagesListServiceProtocol {
    var photos: [Photo] = []
    var fetchPhotosNextPageCalled = false
    var changeLikeCalled = false
    var lastPhotoId: String?
    var lastIsLike: Bool?
    var fetchCompletion: ((Result<[Photo], Error>) -> Void)?
    var changeLikeCompletion: ((Result<Void, Error>) -> Void)?
    
    func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void) {
        fetchPhotosNextPageCalled = true
        fetchCompletion = completion
    }
    
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCalled = true
        lastPhotoId = photoId
        lastIsLike = isLike
        changeLikeCompletion = completion
    }
}

final class ImagesListViewMock: ImagesListViewProtocol {
    
    var updateTableViewAnimatedCalled = false
    var showErrorCalled = false
    var showLoadingCalled = false
    var hideLoadingCalled = false
    var updateCellLikeStatusCalled = false
    var navigateToSingleImageCalled = false
    var lastErrorMessage: String?
    var lastOldCount: Int?
    var lastNewCount: Int?
    var lastIndexPath: IndexPath?
    var lastIsLiked: Bool?
    var lastImageURL: String?
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        updateTableViewAnimatedCalled = true
        lastOldCount = oldCount
        lastNewCount = newCount
    }
    
    func showError(message: String) {
        showErrorCalled = true
        lastErrorMessage = message
    }
    
    func showLoading() {
        showLoadingCalled = true
    }
    
    func hideLoading() {
        hideLoadingCalled = true
    }
    func updateCellLikeStatus(at indexPath: IndexPath, isLiked: Bool) {
        
    }
    
    func navigateToSingleImage(with url: String) {
        navigateToSingleImageCalled = true
        lastImageURL = url  // <--- ЭТА СТРОКА ОБЯЗАТЕЛЬНА
    }
    
}

// MARK: - Updated Presenter with Protocol
final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    // MARK: - Properties
    private weak var view: ImagesListViewProtocol?
    private let imagesListService: ImagesListServiceProtocol  // Используем протокол
    private var photos: [Photo] = []
    private var isLoading = false
    private let dateFormatter: DateFormatter
    
    var photosCount: Int {
        return photos.count
    }
    
    // MARK: - Initializer
    init(view: ImagesListViewProtocol,
         imagesListService: ImagesListServiceProtocol,  // Принимаем протокол
         dateFormatter: DateFormatter) {
        self.view = view
        self.imagesListService = imagesListService
        self.dateFormatter = dateFormatter
    }
    
    // MARK: - Public Methods
    func viewDidLoad() {
        fetchNextPage()
    }
    
    func getPhoto(at index: Int) -> Photo? {
        guard index >= 0, index < photos.count else {
            return nil
        }
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
        guard let photo = getPhoto(at: indexPath.row) else { return }
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
        guard let photo = getPhoto(at: index) else { return }
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

// MARK: - Tests!!!!!
final class ImagesListPresenterTests: XCTestCase {
    
    var sut: ImagesListPresenter!
    var viewMock: ImagesListViewMock!
    var serviceMock: ImagesListServiceMock!
    
    override func setUp() {
        super.setUp()
        viewMock = ImagesListViewMock()
        serviceMock = ImagesListServiceMock()
        sut = ImagesListPresenter(
            view: viewMock,
            imagesListService: serviceMock,  // Теперь передаем мок напрямую
            dateFormatter: createTestDateFormatter()
        )
    }
    
    override func tearDown() {
        sut = nil
        viewMock = nil
        serviceMock = nil
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    private func createTestDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }
    
    private func createTestPhoto(
        id: String = "test-id",
        width: Int = 100,
        height: Int = 200,
        createdAt: Date? = Date(),
        description: String? = "Test Description",
        thumbImageURL: String = "https://test.com/thumb.jpg",
        fullImageURL: String = "https://test.com/full.jpg",
        likedByUser: Bool = false
    ) -> Photo {
        // Создаем UrlsResult
        let urls = UrlsResult(
            raw: "https://test.com/raw.jpg",
            full: fullImageURL,
            regular: "https://test.com/regular.jpg",
            small: "https://test.com/small.jpg",
            thumb: thumbImageURL
        )
        
        // Форматируем Date в ISO строку для PhotoResult
        let dateString: String?
        if let createdAt = createdAt {
            let isoFormatter = ISO8601DateFormatter()
            dateString = isoFormatter.string(from: createdAt)
        } else {
            dateString = nil
        }
        
        // Создаем PhotoResult
        let photoResult = PhotoResult(
            id: id,
            width: width,
            height: height,
            createdAt: dateString,
            description: description,
            urls: urls,
            likedByUser: likedByUser
        )
        
        // Создаем Photo через инициализатор from
        return Photo(from: photoResult)
    }
    
    // MARK: - Тест: viewDidLoad вызывает fetchNextPage
    func testViewDidLoadCallsFetchNextPage() {
        // Given
        XCTAssertFalse(serviceMock.fetchPhotosNextPageCalled)
        
        // When
        sut.viewDidLoad()
        
        // Then
        XCTAssertTrue(serviceMock.fetchPhotosNextPageCalled)
    }
    
    // MARK: - Тест: успешная загрузка фотографий
    func testFetchNextPageSuccessUpdatesTableView() {
        // Given
        let testPhoto = createTestPhoto()
        let expectation = XCTestExpectation(description: "Загрузка фотографий")
        
        viewMock.updateTableViewAnimatedCalled = false
        serviceMock.photos = [testPhoto]
        
        sut.viewDidLoad()
        
        // When
        serviceMock.fetchCompletion?(.success([testPhoto]))
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertTrue(self.viewMock.updateTableViewAnimatedCalled)
            XCTAssertEqual(self.viewMock.lastOldCount, 0)
            XCTAssertEqual(self.viewMock.lastNewCount, 1)
            XCTAssertEqual(self.sut.photosCount, 1)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Тест: обработка ошибки загрузки
    func testFetchNextPageErrorShowsError() {
        // Given
        let testError = NSError(domain: "test", code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Network error"])
        let expectation = XCTestExpectation(description: "Обработка ошибки")
        
        viewMock.showErrorCalled = false
        sut.viewDidLoad()
        
        // When
        serviceMock.fetchCompletion?(.failure(testError))
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertTrue(self.viewMock.showErrorCalled)
            XCTAssertEqual(self.viewMock.lastErrorMessage, "Ошибка загрузки фото: Network error")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Тест: форматирование даты
    func testFormatDate() {
        // Given
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        let testDate = dateFormatter.date(from: "15 января 2024") ?? Date()
        
        // When
        let formattedDate = sut.formatDate(testDate)
        
        // Then
        XCTAssertEqual(formattedDate, "15 января 2024")
    }
    
    // MARK: - Тест: обработка nil даты
    func testFormatNilDate() {
        // Given
        let nilDate: Date? = nil
        
        // When
        let formattedDate = sut.formatDate(nilDate)
        
        // Then
        XCTAssertEqual(formattedDate, "")
    }
    
    // MARK: - Тест: получение фото по индексу
    func testGetPhotoAtIndex() {
        // Given
        let testPhoto = createTestPhoto(id: "test-id-123")
        let expectation = XCTestExpectation(description: "Получение фото")
        
        serviceMock.photos = [testPhoto]
        sut.viewDidLoad()
        serviceMock.fetchCompletion?(.success([testPhoto]))
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let retrievedPhoto = self.sut.getPhoto(at: 0)
            XCTAssertEqual(retrievedPhoto?.id, "test-id-123")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    
    
    // MARK: - Тест: выбор фото для навигации
    func testDidSelectPhoto() {
        // Given
        let testPhoto = createTestPhoto(fullImageURL: "https://test.com/full-image.jpg")
        serviceMock.photos = [testPhoto]
        
        sut.viewDidLoad()
        serviceMock.fetchCompletion?(.success([testPhoto]))
        
        // "Прокручиваем" RunLoop, чтобы выполнить все блоки DispatchQueue.main.async внутри Presenter
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        
        // When
        sut.didSelectPhoto(at: 0)
        
        // Then
        XCTAssertTrue(viewMock.navigateToSingleImageCalled)
        XCTAssertEqual(viewMock.lastImageURL, "https://test.com/full-image.jpg")
    }
    
    // MARK: - Тест: photosCount возвращает правильное значение
    func testPhotosCount() {
        // Given
        let testPhoto1 = createTestPhoto(id: "1")
        let testPhoto2 = createTestPhoto(id: "2")
        let expectation = XCTestExpectation(description: "Проверка количества фото")
        
        XCTAssertEqual(sut.photosCount, 0)
        
        serviceMock.photos = [testPhoto1, testPhoto2]
        sut.viewDidLoad()
        serviceMock.fetchCompletion?(.success([testPhoto1, testPhoto2]))
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(self.sut.photosCount, 2)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
