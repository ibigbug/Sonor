//
//  GalleryStore.swift
//  Sonor
//
//  Created by Yuwei Ba on 7/21/19.
//  Copyright © 2019 Watfaq. All rights reserved.
//

import SwiftUI
import Combine

struct ImageModel: Hashable, Identifiable {
    var id: Int
    var image: UIImage
}

class GalleryStore: ObservableObject {
    @Published var photos: [ImageModel] = []
    
    func loadGallery() {
        let fileManager = FileManager.default
        let galleryFolder = getGalleryRootDirectory()
        do {
            let fileURLs = try fileManager.contentsOfDirectory(atPath: galleryFolder as String)
            photos = fileURLs.enumerated().map{
                guard let image = UIImage(contentsOfFile: galleryFolder.appendingPathComponent($1)) else { return nil }
                return ImageModel(id: $0, image: image)
            }.compactMap{$0}
        } catch {
            print("Failed to load local gallery")
        }
    }
}
