//
//  ContentView.swift
//  Sonor
//
//  Created by Yuwei Ba on 7/2/19.
//  Copyright © 2019 Watfaq. All rights reserved.
//

import SwiftUI

struct ContentView : View {
    @EnvironmentObject var globalStore: GlobalStore
    
    var body: some View {
        LandingView().environmentObject(globalStore)
    }
}


#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
