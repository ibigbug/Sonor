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