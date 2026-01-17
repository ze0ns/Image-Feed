//
//  LaunchScreenViewController.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 15.01.2026.
//


import UIKit

class ImagesListViewController: UIViewController {
    // MARK: - Private Properties
    private let tableView = UITableView()
    private var imageLists =  ImagesListViewController.imagesListMock
    private let cellId = "ImagesListCell"
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yp_Black
        setupTableView()
        configureTable()
    }
    // MARK: - Private Methods
    private func setupTableView() {
        tableView.register(ImageCell.self, forCellReuseIdentifier: cellId)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .yp_Black
        tableView.separatorStyle = .none
    }
    private func configureTable(){
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
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
        let likeImage = (currentImage.like ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off"))
            cell.configure(
                image: currentImage.image,
                islike: likeImage!,
                date: dateFormatter.string(from: Date()),
                maxImageWidth: maxImageWidth
            )
        return cell
    }
}
extension ImagesListViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
//
//MARK: - SwiftUI
import SwiftUI
struct ImagesListVCProvider: PreviewProvider{
    
    static var previews: some View{
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        let tabBarVC = ImagesListViewController()
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<ImagesListVCProvider.ContainerView>) ->
        ImagesListViewController{
            return tabBarVC
        }
        func updateUIViewController(_ uiViewController: ImagesListVCProvider.ContainerView.UIViewControllerType, context: UIViewControllerRepresentableContext<ImagesListVCProvider.ContainerView>) {
            
        }
    }
    
}
