//
//  ShootingFeature.swift
//  Sonor
//
//  Created by Yuwei Ba on 7/5/19.
//  Copyright © 2019 Watfaq. All rights reserved.
//

import SwiftUI

struct ShootingFeature:Hashable, Codable, Identifiable {
    var id: Int
    var name: FeatureName
    var description: String
}

enum FeatureName: String, Codable {
    case MultipleExposure = "Multiple Exposure"
    case SmoothReflection = "Smooth Reflection"
}

var SupportedFeatures = [
    ShootingFeature(id: 0, name: FeatureName.MultipleExposure, description: "Composite your exposures with optimized settings"),
    ShootingFeature(id: 1, name: FeatureName.SmoothReflection, description: "Easily take magical long-exposure photos that normally require an ND filter")
]
