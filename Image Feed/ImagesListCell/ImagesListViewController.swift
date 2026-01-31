//
//  LaunchScreenViewController.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 15.01.2026.
//


import UIKit

final class ImagesListViewController: UIViewController {
    // MARK: - Private Properties
    private let tableView = UITableView()
    private var imageLists =  ImagesListViewController.imagesListMock
    private let cellId = "ImagesListCell"
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
        return imageLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ImageCell
        let currentImage = imageLists[indexPath.row]
        let maxImageWidth = tableView.bounds.width - 16
        cell.configure(
            image: currentImage.image,
            islike: UIImage(resource: currentImage.like ? .likeButtonOn : .likeButtonOff),
            date: dateFormatter.string(from: Date()),
            maxImageWidth: maxImageWidth
        )
        cell.selectionStyle = .none
        return cell
    }
}
extension ImagesListViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentImage = imageLists[indexPath.row]
        imageURL = currentImage.image
        changeRootToDestination()
    }
}

