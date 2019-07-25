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
        NavigationView {
            Form {
                Section {

                    NavigationLink(destination: QRCodeScan()) {
                        TextWithIcon(iconName: "qrcode", text: "Scan QR Code")
                    }
                    NavigationLink(destination: Text("NFC")) {
                        TextWithIcon(iconName: "n.circle", text: "Connect via NFC")
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
                
            }.navigationBarTitle(Text("Connect..."))
        }.navigationViewStyle(.stack)
    }
}

#if DEBUG
struct FindDeviceView_Previews : PreviewProvider {
    static var previews: some View {
        FindDeviceView()
    }
}
#endif

