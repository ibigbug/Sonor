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

struct ShootingFeatureRoute : View {
    var feature: ShootingFeature
    @State var smoothMode: SmoothMode = .Water
    @State var smoothLevel: SmoothLevel = .Low
    
    var body: some View {
        NavigationView {
            
            VStack(alignment: .leading, spacing: 20){
                if feature.name == .MultipleExposure {
                    Text("Multiple Exposure")
                } else if feature.name == .SmoothReflection {
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
                        
                        Spacer()
                        
                        Button(action: shoot) {
                            Text("Shoot")
                        }
                    }
                }
            }
            .padding()
            
            Spacer()
        }
    }
    
    private func shoot() {
        
    }
}
