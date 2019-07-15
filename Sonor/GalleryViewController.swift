//
//  GalleryViewController.swift
//  Sonor
//
//  Created by Yuwei Ba on 7/9/19.
//  Copyright © 2019 Watfaq. All rights reserved.
//

import SwiftUI
import UIKit
import SKPhotoBrowser
import Combine

class GalleryStore: BindableObject {
    let didChange = PassthroughSubject<GalleryStore, Never>()
    var photos: [SKLocalPhoto] = [] {
        didSet {
            self.didChange.send(self)
        }
    }
    
    func loadGallery() {
        let fileManager = FileManager.default
        let galleryFolder = getGalleryRootDirectory()
        do {
            let fileURLs = try fileManager.contentsOfDirectory(atPath: galleryFolder)
            photos = fileURLs.map{ SKLocalPhoto.photoWithImageURL((galleryFolder as NSString).appendingPathComponent($0)) }
        } catch {
            print("Failed to load local gallery")
        }
    }
}

struct GalleryViewController : UIViewControllerRepresentable {
    func makeCoordinator() -> GalleryViewController.Coordinator {
        Coordinator(self)
    }
    
    @ObjectBinding var galleryStore: GalleryStore
    
    let layout = UICollectionViewFlowLayout.init()
    
    init() {
        self.galleryStore = GalleryStore()
    }
    
    func makeUIViewController(context: Context) -> UICollectionViewController {
        
        layout.scrollDirection = .vertical
        
        let ctrl =  UICollectionViewController(collectionViewLayout: layout)
        ctrl.collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "cell")
        ctrl.collectionView.dataSource = context.coordinator
        return ctrl
    }
    
    func updateUIViewController(_ uiViewController: UICollectionViewController, context: Context) {
        self.galleryStore.loadGallery()
    }
    
    class Coordinator: NSObject, UICollectionViewDataSource {
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            self.parent.galleryStore.photos.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageCell
            
            let imageUrl = self.parent.galleryStore.photos[indexPath.row].photoURL
            cell.imageView.image = UIImage(contentsOfFile: imageUrl!)
            return cell
        }
        
        var parent: GalleryViewController
        
        init(_ collectionVC: GalleryViewController) {
            self.parent = collectionVC
        }
    }
}
