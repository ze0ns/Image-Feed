//
//  LaunchScreenViewController.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 15.01.2026.
//


import UIKit

class ImagesListViewController: UIViewController {
    let tableView = UITableView()
    var imageLists =  ImagesListViewController.imagesListMock
    let cellId = "ImagesListCell"
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.10, green: 0.11, blue: 0.13, alpha: 1.00)
        setupTableView()
        configureTable()
    }
    func setupTableView() {
        tableView.register(ImageCell.self, forCellReuseIdentifier: cellId)
        tableView.dataSource = self
      }
    func configureTable(){
        view.addSubview(tableView)
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
}
extension ImagesListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return imageLists.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ImageCell
      let currentImage = imageLists[indexPath.row]
      cell.configure(with: currentImage)
    return cell
  }
}

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
