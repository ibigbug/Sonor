//
//  ContentView.swift
//  Sonor
//
//  Created by Yuwei Ba on 7/2/19.
//  Copyright © 2019 Watfaq. All rights reserved.
//

import SwiftUI

struct ContentView : View {
    @State private var selection = 0
    @EnvironmentObject var globalStore: GlobalStore
    
    var body: some View {
        TabbedView() {
            ShootingLongExposure()
                .tabItem {
                    Image("first")
                    Text("First")
                }
                .tag(0)
            
            GalleryView()
                .tabItem {
                    Image("second")
                    Text("Second")
                }
                .tag(1)
        }
    }
}


#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
