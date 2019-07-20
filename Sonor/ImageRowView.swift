//
//  ImageRowView.swift
//  Sonor
//
//  Created by Yuwei Ba on 7/21/19.
//  Copyright © 2019 Watfaq. All rights reserved.
//

import SwiftUI

struct ImageRowView : View {
    var image: UIImage
    
    var body: some View {
        Image(uiImage: image).resizable()
    }
}
