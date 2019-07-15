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
        NavigationView {
            List(SupportedFeatures) { feature in
                NavigationLink(destination: ShootingFeatureRoute(feature: feature).environmentObject(self.state)) {
                    ShootingFeatureRow(feature: feature)
                }
            }
            .navigationBarTitle(Text("Features List"))
        }.onAppear(perform: findCamera)
    }
    
    private func findCamera() {
        state.findCamera()
    }
}

#if DEBUG
struct ShootingFeatureList_Previews : PreviewProvider {
    static var previews: some View {
        ShootingFeatureList()
    }
}
#endif
