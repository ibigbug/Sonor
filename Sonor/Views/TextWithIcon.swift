//
//  TextWithIcon.swift
//  Sonor
//
//  Created by Yuwei Ba on 7/25/19.
//  Copyright © 2019 Watfaq. All rights reserved.
//

import SwiftUI

struct TextWithIcon : View {
    var iconName: String
    var text: String
    var body: some View {
        HStack {
        Image(systemName: iconName).resizable().cornerRadius(3).frame(width: 25, height: 25).clipped().aspectRatio(contentMode: .fit)
        
        Text(text).foregroundColor(.black).font(.system(size: 20)).frame(alignment: .leading)    }
    }
}

#if DEBUG
struct TextWithIcon_Previews : PreviewProvider {
    static var previews: some View {
        TextWithIcon(iconName: "qrcode", text: "QR Code")
    }
}
#endif
