//
//  SwiftUIView.swift
//  Sonor
//
//  Created by Yuwei Ba on 7/21/19.
//  Copyright © 2019 Watfaq. All rights reserved.
//

import SwiftUI

struct FindDeviceView : View {
    
    @ObjectBinding var state: FindDeviceModel
    
    var body: some View {
        NavigationView {
            Form {
                if state.cameraDiscoverStatus != .CameraFound {
                    Section {

                        NavigationLink(destination: QRCodeScan(state: state)) {
                            TextWithIcon(iconName: "qrcode", text: "QR Code")
                        }
                        NavigationLink(destination: Text("NFC")) {
                            TextWithIcon(iconName: "n.circle", text: "Tap NFC")
                        }
                    }
                }
                
                Section {
                    NavigationLink(destination: Text("Gallery")) {
                        TextWithIcon(iconName: "photo.on.rectangle", text: "Gallery")
                    }
                }
           
                Section {
                    TextWithIcon(iconName: "info.circle", text: "Help")
                    Text("About")
                }
                
            }.navigationBarTitle(Text(self.state.cameraDiscoverStatus.rawValue))
        }.navigationViewStyle(.stack)
    }
}

#if DEBUG
struct FindDeviceView_Previews : PreviewProvider {
    static var previews: some View {
        FindDeviceView(state: FindDeviceModel())
    }
}
#endif

