//
//  ShootingFeatureRoute.swift
//  Sonor
//
//  Created by Yuwei Ba on 7/5/19.
//  Copyright © 2019 Watfaq. All rights reserved.
//

import SwiftUI

enum SmoothMode: String, CaseIterable {
    case Water = "Water"
}
enum SmoothLevel: String, CaseIterable {
    case Low = "Low"
    case Medium = "Medium"
    case High = "High"
}

struct ShootingLongExposure : View {

    @State var smoothMode: SmoothMode = .Water
    @State var smoothLevel: SmoothLevel = .Low
    
    @EnvironmentObject var state: GlobalStore
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                
                Button(action: shoot) {
                    Text("Shoot")
                }
            }
            
            if state.cameraFound {
                VStack(alignment:. leading) {
                    Text("Scenario").bold()
                    
                    SegmentedControl(selection: $smoothMode){
                        ForEach(SmoothMode.allCases.identified(by: \.self)) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    
                    Text("Smooth Level").bold()
                    
                    SegmentedControl(selection: $smoothLevel){
                        ForEach(SmoothLevel.allCases.identified(by: \.self)) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    
                    Text("CV Version: \(OpenCVWrapper.openCVVersionString())")
                }
            }
            else {
                Text("Finding camera")
            }
            
            Spacer()
        }.onAppear {
            self.state.findCamera()
        }
    }
    
    private func shoot() {
        CameraWrapper.shared.actTakePicture(count: 3) { imageUrls in
            let images = imageUrls.map{ UIImage(contentsOfFile: $0) }.compactMap{$0}
            let result = OpenCVWrapper.mergeLongExposure(images)
            saveImage(result)
        }
    }
}
