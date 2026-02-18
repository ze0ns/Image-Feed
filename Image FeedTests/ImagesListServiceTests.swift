//
//  Image_FeedTests.swift
//  Image FeedTests
//
//  Created by Oschepkov Aleksandr on 02.02.2026.
////
//
//@testable import Image_Feed
//import XCTest
//
//final class ImagesListServiceTests: XCTestCase {
//    func testFetchPhotos() {
//        let service = ImagesListService.shared
//        
//        let expectation = self.expectation(description: "Wait for Notification")
//        NotificationCenter.default.addObserver(
//            forName: ImagesListService.didChangeNotification,
//            object: nil,
//            queue: .main) { _ in
//                expectation.fulfill()
//            }
//        
//        service.fetchPhotosNextPage { _ in }
//        wait(for: [expectation], timeout: 10)
//        
//        XCTAssertEqual(service.images.count, 10)
//    }
//}
