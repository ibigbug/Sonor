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

struct CameraSetting {
    var exposureMode: ExposureModeParameter
    var ISO: String
    var whiteBalance: WhiteBalanceModeParameter
    var aperture: String
    var intervalSec: Int
}

enum ExposureScenario: String, CaseIterable, Hashable {
    case WaterFlow = "Water Flow"
    case Twilight = "Twilight Reflection"
    case Silent = "Silent"
    case Smoke = "Smoke Haze"
}

enum SmoothLevel: String, CaseIterable {
    case Low = "Low"
    case Medium = "Medium"
    case High = "High"
}


let ScenarioPreset: [ExposureScenario: CameraSetting] = [
    ExposureScenario.WaterFlow: CameraSetting(exposureMode: ExposureModeParameter.Aperture, ISO: "100", whiteBalance: WhiteBalanceModeParameter.Auto, aperture: "11", intervalSec: 5)
]


var SupportedFeatures = [
    ShootingFeature(id: 0, name: FeatureName.MultipleExposure, description: "Composite your exposures with optimized settings"),
    ShootingFeature(id: 1, name: FeatureName.SmoothReflection, description: "Easily take magical long-exposure photos that normally require an ND filter")
]

enum AppStatus: String {
    case Shooting = "Shooting"
    case Fething = "Fetching"
    case Processing = "Processing"
    case Ready = "Ready"
}
