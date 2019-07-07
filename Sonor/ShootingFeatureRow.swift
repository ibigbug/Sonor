//
//  ShootingFeatureRow.swift
//  Sonor
//
//  Created by Yuwei Ba on 7/5/19.
//  Copyright © 2019 Watfaq. All rights reserved.
//

import SwiftUI

struct ShootingFeatureRow : View {
    var feature: ShootingFeature
    
    var body: some View {
        HStack {
            Text(feature.name.rawValue)
        }
    }
}

#if DEBUG
struct ShootingFeatureRow_Previews : PreviewProvider {
    static var previews: some View {
        ShootingFeatureRow(feature: ShootingFeature(id: 0, name: FeatureName.MultipleExposure, description: "This is a good feature that you can do a lot with it"))
            .previewLayout(.fixed(width: 300, height: 70))
    }
}
#endif
