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
        
        let imageCount = CameraWrapper.shared.getContentCount()
        CameraWrapper.shared.actTakePicture(count: count, intervalSec: cameraSetting.intervalSec) { _ in
            let imageUrls = CameraWrapper.shared.getContentList(startIndex: imageCount, count: count)
            let images = imageUrls.map{ UIImage(contentsOfFile: $0) }.compactMap{$0}
            let result = OpenCVWrapper.mergeLongExposure(images)
            self.longExposureResult = saveImage(result)
        }
    }
    
    func retriveImages(_count: Int, start: Int) {
        
    }
}
