//
//  ShootingFeatureList.swift
//  Sonor
//
//  Created by Yuwei Ba on 7/5/19.
//  Copyright © 2019 Watfaq. All rights reserved.
//

import SwiftUI

struct ShootingFeatureList : View {
    @EnvironmentObject var state: GlobalStore

    var body: some View {
        HStack{
            if state.cameraFound {
                NavigationView {
                    List(self.state.shootingFeatures) { feature in
                        ShootingFeatureRow(feature: feature)
                    }.onAppear(perform: loadApi)
                    .navigationBarTitle(Text("Features List"))
                }
            }
            
            else {
                Text("Finding Camera")
            }
        }.onAppear(perform: findCamera)
    }
    
    private func findCamera() {
        state.findCamera()
    }
    
    private func loadApi() {
        state.loadApi()
    }
}

#if DEBUG
struct ShootingFeatureList_Previews : PreviewProvider {
    static var previews: some View {
        ShootingFeatureList()
    }
}
#endif
