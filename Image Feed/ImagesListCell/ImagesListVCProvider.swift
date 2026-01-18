//
//  ImagesListVCProvider.swift
//  Image Feed
//
//  Created by Oschepkov Aleksandr on 18.01.2026.
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