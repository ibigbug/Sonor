//
//  LandingView.swift
//  Sonor
//
//  Created by Yuwei Ba on 7/21/19.
//  Copyright © 2019 Watfaq. All rights reserved.
//

import SwiftUI

struct LandingView : View {
    @EnvironmentObject var state: GlobalStore
    
    var body: some View {
        if state.cameraFound {
            return AnyView(ShootingLongExposure().environmentObject(state))
        } else {
            return AnyView(FindDeviceView().environmentObject(state))
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
