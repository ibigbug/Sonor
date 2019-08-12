//
//  ShootingModel.swift
//  Sonor
//
//  Created by Yuwei Ba on 8/13/19.
//  Copyright © 2019 Watfaq. All rights reserved.
//

import Foundation

class ShootingModel: ObservableObject {

    @Published var longExposureResult: String = nil
        
    func startShooting(_ count: Int, scenario: ExposureScenario) {
        guard let cameraSetting = ScenarioPreset[scenario] else { return }
        CameraWrapper.shared.setUpCameraSettings(cameraSetting)
        CameraWrapper.shared.actTakePicture(count: count, intervalSec: cameraSetting.intervalSec) { imageUrls in
               let images = imageUrls.map{ UIImage(contentsOfFile: $0) }.compactMap{$0}
               let result = OpenCVWrapper.mergeLongExposure(images)
            self.longExposureResult = saveImage(result)
        }
    }
}
