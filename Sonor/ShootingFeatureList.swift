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
            NavigationView {
                List(SupportedFeatures) { feature in
                    NavigationButton(destination: ShootingFeatureRoute(feature: feature)) {
                        ShootingFeatureRow(feature: feature)
                    }
                }
                .navigationBarTitle(Text("Features List"))
            }
        }
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
