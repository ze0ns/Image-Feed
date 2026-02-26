//
//  ImagesListService.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 02.02.2026.
//

import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}
protocol ImagesListViewProtocol: AnyObject {
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func updateCellLikeStatus(at indexPath: IndexPath, isLiked: Bool)
    func showLoading()
    func hideLoading()
    func showError(message: String)
    func navigateToSingleImage(with url: String)
}

final class ImagesListViewController: UIViewController {
    
    // MARK: - Private Properties
    private let tableView = UITableView()
    private let cellId = "ImagesListCell"
    private var presenter: ImagesListPresenterProtocol?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPresenter()
        setupUI()
        presenter?.viewDidLoad()
    }
    
    // MARK: - Setup
    private func setupPresenter() {
        presenter = ImagesListPresenter(view: self)
    }
    
    private func setupUI() {
        view.backgroundColor = .ypBlack
        setupTableView()
        configureTable()
    }
    
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
}

// MARK: - ImagesListViewProtocol
extension ImagesListViewController: ImagesListViewProtocol {
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map { i in
                IndexPath(row: i, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func updateCellLikeStatus(at indexPath: IndexPath, isLiked: Bool) {
        if let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell {
            cell.setIsLiked(isLiked)
        }
    }
    
    func showLoading() {
        UIBlockingProgressHUD.show()
    }
    
    func hideLoading() {
        UIBlockingProgressHUD.dismiss()
    }
    
    func showError(message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func navigateToSingleImage(with url: String) {
        let singleImageVC = SingleImageViewController()
        singleImageVC.fullImageURL = url
        let navController = UINavigationController(rootViewController: singleImageVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.photosCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? ImagesListCell,
              let photo = presenter?.getPhoto(at: indexPath.row) else {
            return UITableViewCell()
        }
        
        let maxImageWidth = tableView.bounds.width - 32
        let dateString = presenter?.formatDate(photo.createdAt) ?? ""
        
        cell.configure(
            image: photo.thumbImageURL,
            height: photo.height,
            width: photo.width,
            islike: photo.likedByUser,
            date: dateString,
            maxImageWidth: maxImageWidth
        )
        cell.selectionStyle = .none
        cell.delegate = self
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (presenter?.photosCount ?? 0) - 3 {
            presenter?.fetchNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.didSelectPhoto(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let photo = presenter?.getPhoto(at: indexPath.row) else {
            return 0
        }
        let tableViewWidth = tableView.bounds.width - 32
        let aspectRatio = CGFloat(photo.height) / CGFloat(photo.width)
        return tableViewWidth * aspectRatio + 8
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.didTapLike(at: indexPath)
    }
}

