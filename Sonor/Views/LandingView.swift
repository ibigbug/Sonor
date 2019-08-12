//
//  LandingView.swift
//  Sonor
//
//  Created by Yuwei Ba on 7/21/19.
//  Copyright © 2019 Watfaq. All rights reserved.
//

import SwiftUI

struct LandingView : View {
    @ObservedObject var findingState = FindDeviceModel()
    @ObservedObject var shootingModel = ShootingModel()
    
    var body: some View {
        if findingState.cameraDiscoverStatus == .CameraFound {
            return AnyView(ShootingLongExposure(shootingModel: shootingModel))
        } else {
            return AnyView(FindDeviceView(state: findingState))
        }
    }
}

#if DEBUG
struct LandingView_Previews : PreviewProvider {
    static var previews: some View {
        LandingView()
    }
}
#endif
