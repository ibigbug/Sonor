//
//  SwiftUIView.swift
//  Sonor
//
//  Created by Yuwei Ba on 7/21/19.
//  Copyright © 2019 Watfaq. All rights reserved.
//

import SwiftUI

struct FindDeviceView : View {
    var body: some View {
        VStack {
            HStack {
                Text("Title").bold()
            }
        }
    }
}

#if DEBUG
struct FindDeviceView_Previews : PreviewProvider {
    static var previews: some View {
        FindDeviceView()
    }
}
#endif

