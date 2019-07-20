//
//  GalleryView.swift
//  Sonor
//
//  Created by Yuwei Ba on 7/9/19.
//  Copyright © 2019 Watfaq. All rights reserved.
//

import SwiftUI

struct GalleryView: View {
    @EnvironmentObject var gallery: GalleryStore
    var body: some View {
        NavigationView {
            List(gallery.photos) { imageModel in
                NavigationLink(destination: ImageView().environmentObject(self.gallery)) {
                    ImageRowView(image:imageModel.image)
                }
            }
        }.navigationBarTitle("Gallery")
        .onAppear(perform: {
            self.gallery.loadGallery()
        })
    }
}

#if DEBUG
struct GalleryView_Previews : PreviewProvider {
    static var previews: some View {
        GalleryView()
    }
}
#endif
